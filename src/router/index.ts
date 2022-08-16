import { pathToRegexp, match } from 'path-to-regexp'
import { stackRouteHandler } from './stack'
import { tabsRouteHandler } from './tabs'
import { drawerRouteHandler } from './drawer'
import { Navigator } from '../Navigator'
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

interface IndexType {
  [index: string]: any
}

let routeDatas = new Map<string, RouteData>()
let interceptors = new Set<RouteInterceptor>()
let handlers = new Set<RouteHandler>([drawerRouteHandler, tabsRouteHandler, stackRouteHandler])

const traverseHandlers: RouteHandler = async (
  graph: RouteGraph,
  route: RouteInfo,
  next: RouteHandler,
) => {
  for (let handler of handlers.values()) {
    if (await handler(graph, route, next)) {
      return true
    }
  }
  return false
}

function addInterceptor(func: RouteInterceptor) {
  interceptors.add(func)
}

function removeInterceptor(func: RouteInterceptor) {
  interceptors.delete(func)
}

function use(handler: RouteHandler) {
  handlers.add(handler)
}

function registerRoute(moduleName: string, route: RouteConfig) {
  let { path, dependency, mode } = route
  let regexp: RegExp | undefined
  if (path) {
    if (!path.startsWith('/')) {
      route.path = '/' + route.path
    }
    regexp = pathToRegexp(path)
  }
  mode = mode || 'push'
  routeDatas.set(moduleName, { moduleName, mode, path, regexp, dependency })
}

let isRouteConfigInflated = false

function inflateRouteConfigs() {
  const routeConfigs = Navigation.routeConfigs()
  for (const [moduleName, config] of routeConfigs) {
    registerRoute(moduleName, config)
  }
}

async function open(path: string, props: object = {}, options: NavigationItem = {}) {
  if (!isRouteConfigInflated) {
    inflateRouteConfigs()
    isRouteConfigInflated = true
  }

  let intercepted = false
  for (let interceptor of interceptors.values()) {
    const result = interceptor(path)
    if (result instanceof Promise) {
      intercepted = await result
    } else {
      intercepted = result
    }

    if (intercepted) {
      return
    }
  }

  const route = pathToRoute(path, props, options)

  if (!route) {
    return
  }

  const graphArray = await Navigator.routeGraph()
  if (graphArray.length > 1) {
    for (let index = graphArray.length - 1; index > 0; index--) {
      const { mode: layoutMode } = graphArray[index]
      const navigator = await Navigator.current()
      if (layoutMode === 'present') {
        await navigator.dismiss()
      } else if (layoutMode === 'modal') {
        await navigator.hideModal()
      } else {
        console.warn('尚未处理的 layout mode:' + layoutMode)
      }
    }
  }

  if (!(await traverseHandlers(graphArray[0], route, traverseHandlers))) {
    const navigator = await Navigator.current()
    navigator.closeMenu()
    const { moduleName, mode: routeMode, props: initialProps } = route
    if (routeMode === 'present') {
      navigator.present(moduleName, initialProps)
    } else if (routeMode === 'modal') {
      navigator.showModal(moduleName, initialProps)
    } else {
      // default push
      navigator.push(moduleName, initialProps)
    }
  }
}

function pathToRoute(path: string, props: object, options: NavigationItem): RouteInfo | undefined {
  for (const data of routeDatas.values()) {
    if (!data.regexp) {
      continue
    }

    const [pathName, queryString] = path.split('?')

    if (data.regexp.exec(pathName)) {
      const moduleName = data.moduleName
      const params = pathParams(pathName)
      const query = queryParams(queryString)
      props = { ...query, ...params, ...props }
      const dependencies = routeDependencies(data)
      const mode = data.mode
      return { moduleName, props, dependencies, mode, options }
    }
  }
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

function routeDependencies(routeData: RouteData) {
  let dependencies: string[] = []
  let data: RouteData | undefined = routeData
  while (data && data.dependency) {
    dependencies.push(data.dependency)
    data = routeDatas.get(data.dependency)
  }
  return dependencies.reverse()
}

export const router = {
  addInterceptor,
  removeInterceptor,
  registerRoute,
  use,
  open,
  pathToRoute,
}

export * from './drawer'
export * from './screen'
export * from './stack'
export * from './tabs'
