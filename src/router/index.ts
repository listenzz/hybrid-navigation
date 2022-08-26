import { pathToRegexp, match } from 'path-to-regexp'
import {
  RouteConfig,
  RouteData,
  RouteGraph,
  RouteHandler,
  RouteInfo,
  RouteInterceptor,
} from '../Route'
import { NavigationItem } from '../Options'
import Navigation from '../Navigation'
import { StackRouteHandler } from './stack'
import { ScreenRouteHandler } from './screen'
import { TabsRouteHandler } from './tabs'
import { DrawerRouteHandler } from './drawer'

interface IndexType {
  [index: string]: any
}

function pathParams(path: string) {
  const pathMatch = match<IndexType>(path, {
    encode: encodeURI,
    decode: decodeURIComponent,
  })(path)
  return pathMatch ? pathMatch.params : {}
}

function queryParams(queryString: string) {
  return (queryString || '').split('&').reduce((result: IndexType, item: string) => {
    if (item !== '') {
      const nextResult = result || {}
      const [key, value] = item.split('=')
      nextResult[key] = value
      return nextResult
    }
    return result
  }, {})
}

class Router {
  constructor() {
    this.registerRouteHandler('screen', new ScreenRouteHandler())
    this.registerRouteHandler('stack', new StackRouteHandler())
    this.registerRouteHandler('tabs', new TabsRouteHandler())
    this.registerRouteHandler('drawer', new DrawerRouteHandler())
  }

  private handlers = new Map<string, RouteHandler>()

  registerRouteHandler(layout: string, handler: RouteHandler) {
    this.handlers.set(layout, handler)
  }

  private convertConfigToData(moduleName: string, route: RouteConfig) {
    let { path, dependency, mode } = route
    let regexp: RegExp | undefined
    if (path) {
      if (!path.startsWith('/')) {
        route.path = '/' + route.path
      }
      regexp = pathToRegexp(path)
    }
    mode = mode || 'push'
    return { moduleName, mode, path, regexp, dependency }
  }

  private isRouteConfigInflated = false
  private routeDataSet = new Map<string, RouteData>()

  private inflateRouteData() {
    if (this.isRouteConfigInflated) {
      return
    }
    this.isRouteConfigInflated = true
    const routeConfigs = Navigation.routeConfigs()
    for (const [moduleName, config] of routeConfigs) {
      const data = this.convertConfigToData(moduleName, config)
      this.routeDataSet.set(moduleName, data)
    }
  }

  private interceptors: RouteInterceptor[] = []

  addInterceptor(interceptor: RouteInterceptor) {
    this.interceptors.push(interceptor)
  }

  removeInterceptor(interceptor: RouteInterceptor) {
    this.interceptors = this.interceptors.filter(item => item !== interceptor)
  }

  private async intercept(path: string) {
    for (let interceptor of this.interceptors.values()) {
      const result = interceptor(path)
      const intercepted = await this.resolveInterceptResult(result)
      if (intercepted) {
        return true
      }
    }
    return false
  }

  private resolveInterceptResult(result: boolean | Promise<boolean>) {
    if (result instanceof Promise) {
      return result
    }
    return Promise.resolve(result)
  }

  private pathToRoute(path: string, props: object, options: NavigationItem): RouteInfo | undefined {
    for (const data of this.routeDataSet.values()) {
      if (!data.regexp) {
        continue
      }

      const [pathName, queryString] = path.split('?')

      if (data.regexp.exec(pathName)) {
        const moduleName = data.moduleName
        const params = pathParams(pathName)
        const query = queryParams(queryString)
        props = { ...query, ...params, ...props }
        const dependencies = this.routeDependencies(data)
        const mode = data.mode
        return { moduleName, props, dependencies, mode, options }
      }
    }
  }

  private routeDependencies(routeData: RouteData) {
    let dependencies: string[] = []
    let data: RouteData | undefined = routeData
    while (data && data.dependency) {
      dependencies.push(data.dependency)
      data = this.routeDataSet.get(data.dependency)
    }
    return dependencies.reverse()
  }

  private async processRoute(route: RouteInfo, graph: RouteGraph): Promise<boolean> {
    const handler = this.handlers.get(graph.layout)
    if (!handler) {
      return false
    }

    const [consumed, childGraph] = await handler.process(graph, route)
    if (consumed && childGraph) {
      return await this.processRoute(route, childGraph)
    }
    return consumed
  }

  async open(path: string, props: IndexType = {}, options: NavigationItem = {}) {
    this.inflateRouteData()

    const intercepted = await this.intercept(path)
    if (intercepted) {
      return
    }

    const route = this.pathToRoute(path, props, options)
    if (!route) {
      return
    }

    const graphArray = await Navigation.routeGraph()
    if (graphArray.length > 1) {
      for (let index = graphArray.length - 1; index > 0; index--) {
        const { mode: layoutMode } = graphArray[index]
        const { sceneId, moduleName } = await Navigation.currentRoute()
        if (layoutMode === 'present') {
          await Navigation.dispatch(sceneId, 'dismiss', { from: moduleName })
        } else if (layoutMode === 'modal') {
          await Navigation.dispatch(sceneId, 'hideModal', { from: moduleName })
        } else {
          console.warn('尚未处理的 layout mode:' + layoutMode)
        }
      }
    }

    const routeGraph = graphArray[0]

    const consumed = await this.processRoute(route, routeGraph)
    if (consumed) {
      return
    }

    const { sceneId, moduleName: from } = await Navigation.currentRoute()
    Navigation.dispatch(sceneId, 'closeMenu', { from })
    const { moduleName, mode: routeMode, props: initialProps } = route
    let action = 'push'
    if (routeMode === 'present') {
      action = 'present'
    } else if (routeMode === 'modal') {
      action = 'showModal'
    }
    Navigation.dispatch(sceneId, action, {
      moduleName,
      props: initialProps,
      from,
      to: moduleName,
    })
  }
}

export const router = new Router()

export * from './drawer'
export * from './screen'
export * from './stack'
export * from './tabs'
