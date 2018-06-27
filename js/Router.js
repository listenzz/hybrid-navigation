import pathToRegexp from 'path-to-regexp';
import { Linking } from 'react-native';
import Navigation from './Navigation';
import NavigationModule from './NavigationModule';

let configs = new Map();
let intercepters = new Set();
let active = 0;

function dependenciesForRoute(config = {}) {
  let dependencies = [];
  while (config && config.dependency) {
    dependencies.push(config.dependency);
    config = configs.get(config.dependency);
  }
  return dependencies.reverse();
}

function navigateTo(graph, route) {
  if (graph.type === 'drawer') {
    const drawer = graph.drawer;
    if (navigateTo(drawer[0], route)) {
      const navigation = getNavigationForGraph(drawer[0]);
      navigation.closeMenu();
      return true;
    }
    if (navigateTo(drawer[1], route)) {
      // 打开侧边栏
      const navigation = getNavigationForGraph(drawer[0]);
      navigation.openMenu();
      return true;
    }
  } else if (graph.type === 'tabs') {
    const tabs = graph.tabs;
    for (let i = 0; i < tabs.length; i++) {
      if (navigateTo(tabs[i], route)) {
        if (i !== graph.selectedIndex) {
          const navigation = getNavigationForGraph(tabs[graph.selectedIndex]);
          navigation.switchToTab(i);
        }
        return true;
      }
    }
  } else if (graph.type === 'stack') {
    const stack = graph.stack;
    let moduleNames = [...route.dependencies, route.moduleName];
    let index = -1;
    for (let i = stack.length - 1; i > -1; i--) {
      if (stack[i].type === 'screen') {
        const screen = stack[i].screen;
        index = moduleNames.indexOf(screen.moduleName);
        if (index !== -1) {
          break;
        }
      }
    }
    if (index !== -1) {
      let peddingModuleNames = moduleNames.slice(index + 1);
      const navigation = getNavigationForGraph(graph);
      if (peddingModuleNames.length === 0) {
        navigation.replace(route.moduleName, route.props);
      } else {
        for (let i = 0; i < peddingModuleNames.length; i++) {
          if (i === peddingModuleNames.length - 1) {
            navigation.push(route.moduleName, route.props);
          } else {
            navigation.push(peddingModuleNames[i]);
          }
        }
      }
      return true;
    }
  } else if (graph.type === 'screen') {
    const screen = graph.screen;
    if (screen.moduleName === route.moduleName) {
      return true;
    }
  }
  return false;
}

function getNavigationForGraph(graph) {
  if (graph.type === 'drawer') {
    const drawer = graph.drawer;
    return getNavigationForGraph(drawer[0]);
  } else if (graph.type === 'tabs') {
    const tabs = graph.tabs;
    return getNavigationForGraph(tabs[graph.selectedIndex]);
  } else if (graph.type === 'stack') {
    const stack = graph.stack;
    return getNavigationForGraph(stack[0]);
  } else if (graph.type === 'screen') {
    const screen = graph.screen;
    return new Navigation(screen.sceneId);
  }
  return null;
}

class Router {
  constructor() {
    this._routeEventHandler = this._routeEventHandler.bind(this);
    this.hasHandleInitialURL = false;
  }

  clear() {
    active = 0;
    configs.clear();
  }

  routeGraph() {
    return NavigationModule.routeGraph();
  }

  currentRoute() {
    return NavigationModule.currentRoute();
  }

  addRoute(key, config = {}) {
    if (config.path) {
      config.pathRegexp = pathToRegexp(config.path);
      let params = pathToRegexp.parse(config.path).slice(1);
      config.paramNames = [];
      for (let i = 0; i < params.length; i++) {
        config.paramNames.push(params[i].name);
      }
    }
    config.moduleName = key;
    configs.set(key, config);
  }

  registerIntercepter(func) {
    intercepters.add(func);
  }

  unregisterIntercepter(func) {
    intercepters.delete(func);
  }

  pathToRoute(path) {
    for (const config of configs.values()) {
      if (!config.pathRegexp) {
        continue;
      }
      const match = config.pathRegexp.exec(path);
      if (match) {
        const moduleName = config.moduleName;
        const props = {};
        const names = config.paramNames;
        for (let i = 0; i < names.length; i++) {
          props[names[i]] = match[i + 1];
        }
        const dependencies = dependenciesForRoute(config);
        return { moduleName, props, dependencies, mode: config.mode };
      }
    }
    return {};
  }

  async open(path) {
    if (!path) {
      return;
    }

    let intercept = false;
    for (let intercepter of intercepters.values()) {
      intercept = intercepter(path);
      if (intercept) {
        return;
      }
    }

    const route = this.pathToRoute(path);
    if (route && route.moduleName) {
      try {
        const graph = await this.routeGraph();
        if (route.mode === 'modal') {
          let navigation = getNavigationForGraph(graph[0]);
          navigation.present(route.moduleName, 0, route.props);
        } else {
          // push
          if (graph.length > 1) {
            let navigation = getNavigationForGraph(graph[1]);
            navigation.dismiss();
          }
          if (!navigateTo(graph[0], route)) {
            let navigation = getNavigationForGraph(graph[0]);
            navigation.closeMenu();
            navigation.push(route.moduleName, route.props);
          }
        }
      } catch (error) {
        console.warn(error);
      }
    }
  }

  activate(uriPrefix) {
    if (!uriPrefix) {
      throw new Error('must pass `uriPrefix` when activate router.');
    }
    if (active == 0) {
      this.uriPrefix = uriPrefix;
      if (!this.hasHandleInitialURL) {
        this.hasHandleInitialURL = true;
        Linking.getInitialURL()
          .then(url => {
            if (url) {
              const path = url.replace(this.uriPrefix, '');
              this.open(path);
            }
          })
          .catch(err => console.error('An error occurred', err));
      }
      Linking.addEventListener('url', this._routeEventHandler);
    }
    active++;
  }

  inactivate() {
    active--;
    if (active == 0) {
      Linking.removeEventListener('url', this._routeEventHandler);
    }
  }

  _routeEventHandler(event) {
    console.info(`deeplink:${event.url}`);
    const path = event.url.replace(this.uriPrefix, '');
    this.open(path);
  }
}

const router = new Router();
export default router;
