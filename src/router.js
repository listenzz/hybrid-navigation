import pathToRegexp from 'path-to-regexp';
import { Linking } from 'react-native';
import Navigator from './Navigator';

function routeDependencies(routeConfig) {
  let dependencies = [];
  while (routeConfig && routeConfig.dependency) {
    dependencies.push(routeConfig.dependency);
    routeConfig = configs.get(routeConfig.dependency);
  }
  return dependencies.reverse();
}

const screenParser = {
  navigatorFromRouteGraph(router, graph) {
    const { layout, sceneId } = graph;
    if (sceneId && layout === 'screen') {
      return Navigator.get(sceneId);
    }
    return null;
  },

  navigateTo(router, graph, route) {
    const { layout } = graph;
    const { moduleName, mode, props } = route;
    if (layout === 'screen' && (mode === 'present' || mode === 'modal')) {
      const navigator = router.navigatorFromRouteGraph(graph);
      if (mode === 'present') {
        navigator.present(moduleName, 0, props);
      } else {
        navigator.showModal(moduleName, 0, props);
      }
      return true;
    }
    return false;
  },
};

const stackParser = {
  navigatorFromRouteGraph(router, graph) {
    const { layout, children } = graph;
    if (layout === 'stack') {
      return router.navigatorFromRouteGraph(children[0]);
    }
    return null;
  },

  navigateTo(router, graph, route) {
    const { layout, children } = graph;
    const { mode, moduleName, dependencies, props } = route;

    if (layout !== 'stack') {
      return false;
    }
    if (router.navigateTo(children[0], route)) {
      return true;
    }

    if (mode !== 'push') {
      return false;
    }

    let moduleNames = [...dependencies, moduleName];
    let index = -1;
    for (let i = children.length - 1; i > -1; i--) {
      const { layout, moduleName } = children[i];
      if (layout === 'screen') {
        index = moduleNames.indexOf(moduleName);
        if (index !== -1) {
          break;
        }
      }
    }

    if (index !== -1) {
      let peddingModuleNames = moduleNames.slice(index + 1);
      const navigator = router.navigatorFromRouteGraph(graph);
      if (peddingModuleNames.length === 0) {
        navigator.replace(moduleName, props);
      } else {
        for (let i = 0; i < peddingModuleNames.length; i++) {
          if (i === peddingModuleNames.length - 1) {
            navigator.push(moduleName, props);
          } else {
            navigator.push(peddingModuleNames[i]);
          }
        }
      }
      return true;
    }

    return false;
  },
};

const tabsParser = {
  navigatorFromRouteGraph(router, graph = {}) {
    const { layout, state, children } = graph;
    if (layout === 'tabs') {
      return router.navigatorFromRouteGraph(children[state.selectedIndex]);
    }
    return null;
  },

  navigateTo(router, graph = {}, route) {
    const { layout, children, state } = graph;
    if (layout === 'tabs') {
      for (let i = 0; i < children.length; i++) {
        if (router.navigateTo(children[i], route)) {
          if (i !== state.selectedIndex) {
            console.info('state:' + state.selectedIndex);
            const navigator = router.navigatorFromRouteGraph(graph);
            navigator.switchTab(i);
          }
          return true;
        }
      }
    }
    return false;
  },
};

const drawerParser = {
  navigatorFromRouteGraph(router, graph = {}) {
    const { layout, children } = graph;
    if (layout === 'drawer') {
      return router.navigatorFromRouteGraph(children[0]);
    }
    return null;
  },

  navigateTo(router, graph = {}, route) {
    const { layout, children } = graph;
    if (layout === 'drawer') {
      if (router.navigateTo(children[0], route) || router.navigateTo(children[1], route)) {
        const navigator = router.navigatorFromRouteGraph(graph);
        navigator.closeMenu();
        return true;
      }

      const { moduleName } = children[1];
      if (moduleName === route.moduleName) {
        const navigator = router.navigatorFromRouteGraph(graph);
        navigator.openMenu();
        return true;
      }
    }
    return false;
  },
};

let configs = new Map();
let interceptors = new Set();
let active = 0;
let parsers = new Set([stackParser, screenParser, tabsParser, drawerParser]);

class Router {
  constructor() {
    this._routeEventHandler = this._routeEventHandler.bind(this);
    this.hasHandleInitialURL = false;
  }

  clear() {
    active = 0;
    configs.clear();
  }

  addRouteConfig(key, routeConfig = {}) {
    if (routeConfig.path) {
      routeConfig.pathRegexp = pathToRegexp(routeConfig.path);
      let params = pathToRegexp.parse(routeConfig.path).slice(1);
      routeConfig.paramNames = [];
      for (let i = 0; i < params.length; i++) {
        routeConfig.paramNames.push(params[i].name);
      }
    }
    routeConfig.moduleName = key;
    routeConfig.mode = routeConfig.mode || 'push';
    configs.set(key, routeConfig);
  }

  registerInterceptor(func) {
    interceptors.add(func);
  }

  unregisterInterceptor(func) {
    interceptors.delete(func);
  }

  registerParser(parser) {
    parsers.add(parser);
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

  navigatorFromRouteGraph(graph = {}) {
    for (let parser of parsers.values()) {
      const navigator = parser.navigatorFromRouteGraph(this, graph);
      if (navigator) {
        return navigator;
      }
    }
    throw new Error(
      '找不到合适的 navigator，如果你使用了自定义容器，请为该容器实现 RouteParser 并注册。'
    );
  }

  navigateTo(graph = {}, route) {
    for (let parser of parsers.values()) {
      if (parser.navigateTo(this, graph, route)) {
        return true;
      }
    }
    return false;
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
        const graph = await Navigator.routeGraph();

        if (graph.length > 1) {
          const { mode } = graph[1];
          const navigator = this.navigatorFromRouteGraph(graph[1]);
          if (mode === 'present') {
            navigator.dismiss();
          } else if (mode === 'modal') {
            navigator.hideModal();
          } else {
            console.warn('尚未处理的 mode:' + mode);
          }
        }
        if (!this.navigateTo(graph[0], route)) {
          let navigator = this.navigatorFromRouteGraph(graph[0]);
          navigator.closeMenu();
          navigator.push(route.moduleName, route.props);
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

    if (active < 0) {
      active = 0;
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
