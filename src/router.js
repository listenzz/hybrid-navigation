import pathToRegexp from 'path-to-regexp';
import { Linking } from 'react-native';
import Navigator from './Navigator';
import NavigationModule from './NavigationModule';

let configs = new Map();
let interceptors = new Set();
let active = 0;

function routeDependencies(routeConfig) {
  let dependencies = [];
  while (routeConfig && routeConfig.dependency) {
    dependencies.push(routeConfig.dependency);
    routeConfig = configs.get(routeConfig.dependency);
  }
  return dependencies.reverse();
}

function navigateTo(graph, route) {
  if (graph.type === 'drawer') {
    const drawer = graph.drawer;
    if (navigateTo(drawer[0], route)) {
      const navigation = navigatorFromRouteGraph(drawer[0]);
      navigation.closeMenu();
      return true;
    }
    if (navigateTo(drawer[1], route)) {
      // 打开侧边栏
      const navigation = navigatorFromRouteGraph(drawer[0]);
      navigation.openMenu();
      return true;
    }
  } else if (graph.type === 'tabs') {
    const tabs = graph.tabs;
    for (let i = 0; i < tabs.length; i++) {
      if (navigateTo(tabs[i], route)) {
        if (i !== graph.selectedIndex) {
          const navigation = navigatorFromRouteGraph(tabs[graph.selectedIndex]);
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
      const navigation = navigatorFromRouteGraph(graph);
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

function navigatorFromRouteGraph(graph) {
  if (graph.type === 'drawer') {
    const drawer = graph.drawer;
    return navigatorFromRouteGraph(drawer[0]);
  } else if (graph.type === 'tabs') {
    const tabs = graph.tabs;
    return navigatorFromRouteGraph(tabs[graph.selectedIndex]);
  } else if (graph.type === 'stack') {
    const stack = graph.stack;
    return navigatorFromRouteGraph(stack[0]);
  } else if (graph.type === 'screen') {
    const screen = graph.screen;
    return new Navigator(screen.sceneId);
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

  async routeGraph() {
    return await NavigationModule.routeGraph();
  }

  async currentRoute() {
    return await NavigationModule.currentRoute();
  }

  addRoute(key, routeConfig = {}) {
    if (routeConfig.path) {
      routeConfig.pathRegexp = pathToRegexp(routeConfig.path);
      let params = pathToRegexp.parse(routeConfig.path).slice(1);
      routeConfig.paramNames = [];
      for (let i = 0; i < params.length; i++) {
        routeConfig.paramNames.push(params[i].name);
      }
    }
    routeConfig.moduleName = key;
    configs.set(key, routeConfig);
  }

  registerInterceptor(func) {
    interceptors.add(func);
  }

  unregisterInterceptor(func) {
    interceptors.delete(func);
  }

  pathToRoute(path) {
    for (const routeConfig of configs.values()) {
      if (!routeConfig.pathRegexp) {
        continue;
      }
      const match = routeConfig.pathRegexp.exec(path);
      if (match) {
        const moduleName = routeConfig.moduleName;
        const props = {};
        const names = routeConfig.paramNames;
        for (let i = 0; i < names.length; i++) {
          props[names[i]] = match[i + 1];
        }
        const dependencies = routeDependencies(routeConfig);
        return { moduleName, props, dependencies, mode: routeConfig.mode };
      }
    }
    return {};
  }

  async open(path) {
    if (!path) {
      return;
    }

    let intercepted = false;
    for (let interceptor of interceptors.values()) {
      intercepted = interceptor(path);
      if (intercepted) {
        return;
      }
    }

    const route = this.pathToRoute(path);
    if (route && route.moduleName) {
      try {
        const graph = await this.routeGraph();
        if (route.mode === 'modal') {
          let navigation = navigatorFromRouteGraph(graph[0]);
          navigation.present(route.moduleName, 0, route.props);
        } else {
          // push
          if (graph.length > 1) {
            let navigation = navigatorFromRouteGraph(graph[1]);
            navigation.dismiss();
          }
          if (!navigateTo(graph[0], route)) {
            let navigation = navigatorFromRouteGraph(graph[0]);
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

export function route(path, config = {}) {
  config.path = path;
  return function(constructor) {
    constructor.routeConfig = config;
  };
}

export default router;
