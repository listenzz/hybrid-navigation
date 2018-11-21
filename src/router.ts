import pathToRegexp from 'path-to-regexp';
import { Linking } from 'react-native';
import { Navigator } from './Navigator';

interface NavigationProps {
  [propName: string]: any;
}

export interface Route {
  moduleName: string;
  sceneId: string;
}

export interface RouteInfo {
  mode?: 'modal' | 'present' | 'push';
  moduleName?: string;
  dependencies?: string[];
  props?: object;
}

export interface RouteConfig {
  dependency?: string;
  path?: string;
  pathRegexp?: RegExp;
  moduleName?: string;
  mode?: 'modal' | 'present' | 'push';
  paramNames?: (string | number)[];
}

export interface RouteGraph {
  layout: string;
  sceneId: string;
  mode: 'modal' | 'present' | 'normal';
  children?: RouteGraph[];
  moduleName?: string;
  [propName: string]: any;
}

export type RouteInterceptor = (path: string) => boolean;

export interface RouteParser {
  navigateTo(router: Router, graph: RouteGraph, route: RouteInfo): boolean;
}

function routeDependencies(routeConfig?: RouteConfig) {
  let dependencies: string[] = [];
  while (routeConfig && routeConfig.dependency) {
    dependencies.push(routeConfig.dependency);
    routeConfig = configs.get(routeConfig.dependency);
  }
  return dependencies.reverse();
}

const stackParser: RouteParser = {
  navigateTo(_: Router, graph: RouteGraph, route: RouteInfo) {
    const { layout, children } = graph;
    const { mode, moduleName, dependencies, props } = route;

    if (layout === 'stack' && mode === 'push') {
      let moduleNames = [...dependencies!, moduleName];
      let index = -1;
      for (let i = children!.length - 1; i > -1; i--) {
        const { layout, moduleName } = children![i];
        if (layout === 'screen') {
          index = moduleNames.indexOf(moduleName!);
          if (index !== -1) {
            break;
          }
        }
      }

      if (index !== -1) {
        let peddingModuleNames = moduleNames.slice(index + 1);
        const navigator = new Navigator(children![children!.length - 1].sceneId);
        if (peddingModuleNames.length === 0) {
          navigator.replace(moduleName!, props);
        } else {
          for (let i = 0; i < peddingModuleNames.length; i++) {
            if (i === peddingModuleNames.length - 1) {
              navigator.push(moduleName!, props);
            } else {
              navigator.push(peddingModuleNames[i]!);
            }
          }
        }
        return true;
      }
    }

    return false;
  },
};

const tabsParser: RouteParser = {
  navigateTo(router: Router, graph: RouteGraph, route: RouteInfo) {
    const { layout, children, state } = graph;
    if (layout === 'tabs') {
      for (let i = 0; i < children!.length; i++) {
        if (router.navigateTo(children![i], route)) {
          if (i !== state.selectedIndex) {
            console.info('state:' + state.selectedIndex);
            const navigator = new Navigator(children![i].sceneId);
            navigator.switchTab(i);
          }
          return true;
        }
      }
    }
    return false;
  },
};

const drawerParser: RouteParser = {
  navigateTo(router: Router, graph: RouteGraph, route: RouteInfo) {
    const { layout, children } = graph;
    if (layout === 'drawer') {
      if (router.navigateTo(children![0], route) || router.navigateTo(children![1], route)) {
        const navigator = new Navigator(children![0].sceneId);
        navigator.closeMenu();
        return true;
      }

      const { moduleName } = children![1];
      if (moduleName === route.moduleName) {
        const navigator = new Navigator(children![1].sceneId);
        navigator.openMenu();
        return true;
      }
    }
    return false;
  },
};

let configs = new Map<string, RouteConfig>();
let interceptors = new Set<RouteInterceptor>();
let active = 0;
let parsers = new Set<RouteParser>([drawerParser, tabsParser, stackParser]);

class Router {
  private hasHandleInitialURL: boolean;
  private uriPrefix?: string;
  constructor() {
    this.routeEventHandler = this.routeEventHandler.bind(this);
    this.hasHandleInitialURL = false;
  }

  clear() {
    active = 0;
    configs.clear();
  }

  addRouteConfig(key: string, routeConfig: RouteConfig = {}) {
    if (routeConfig.path) {
      routeConfig.pathRegexp = pathToRegexp(routeConfig.path);
      let params = pathToRegexp.parse(routeConfig.path).slice(1);
      routeConfig.paramNames = [];
      for (let i = 0; i < params.length; i++) {
        const key: pathToRegexp.Key = params[i] as pathToRegexp.Key;
        routeConfig.paramNames.push(key.name);
      }
    }
    routeConfig.moduleName = key;
    routeConfig.mode = routeConfig.mode || 'push';
    configs.set(key, routeConfig);
  }

  registerInterceptor(func: RouteInterceptor) {
    interceptors.add(func);
  }

  unregisterInterceptor(func: RouteInterceptor) {
    interceptors.delete(func);
  }

  registerParser(parser: RouteParser) {
    parsers.add(parser);
  }

  pathToRoute(path: string): RouteInfo {
    for (const routeConfig of configs.values()) {
      if (!routeConfig.pathRegexp) {
        continue;
      }
      const match = routeConfig.pathRegexp.exec(path);
      if (match) {
        const moduleName = routeConfig.moduleName;
        const props: NavigationProps = {};
        const names = routeConfig.paramNames;
        if (names) {
          for (let i = 0; i < names.length; i++) {
            props[names[i]] = match[i + 1];
          }
        }
        const dependencies = routeDependencies(routeConfig);
        return { moduleName, props, dependencies, mode: routeConfig.mode };
      }
    }
    return {};
  }

  navigateTo(graph: RouteGraph, route: RouteInfo) {
    for (let parser of parsers.values()) {
      if (parser.navigateTo(this, graph, route)) {
        return true;
      }
    }
    return false;
  }

  async open(path: string) {
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
        const graphArray = await Navigator.routeGraph();

        if (graphArray.length > 1) {
          for (let index = graphArray.length - 1; index > 0; index--) {
            const { mode: layoutMode } = graphArray[index];
            const navigator = await Navigator.current();
            if (layoutMode === 'present') {
              navigator.dismiss();
            } else if (layoutMode === 'modal') {
              navigator.hideModal();
            } else {
              console.warn('尚未处理的 mode:' + layoutMode);
            }
          }
        }

        if (!this.navigateTo(graphArray[0], route)) {
          const navigator = await Navigator.current();
          navigator.closeMenu();
          const { moduleName, mode: routeMode, props } = route;
          if (routeMode === 'present') {
            navigator.present(moduleName, 0, props);
          } else if (routeMode === 'modal') {
            navigator.showModal(moduleName, 0, props);
          } else {
            // default push
            navigator.push(moduleName, props);
          }
        }
      } catch (error) {
        console.warn(error);
      }
    }
  }

  activate(uriPrefix: string) {
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
              const path = url.replace(this.uriPrefix!, '');
              this.open(path);
            }
          })
          .catch(err => console.error('An error occurred', err));
      }
      Linking.addEventListener('url', this.routeEventHandler);
    }
    active++;
  }

  inactivate() {
    active--;
    if (active == 0) {
      Linking.removeEventListener('url', this.routeEventHandler);
    }

    if (active < 0) {
      active = 0;
    }
  }

  private routeEventHandler(event: { url: string }): void {
    console.info(`deeplink:${event.url}`);
    const path = event.url.replace(this.uriPrefix!, '');
    this.open(path);
  }
}

const router = new Router();
export { router };
