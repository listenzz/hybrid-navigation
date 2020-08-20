import { IndexType, Navigator } from '../Navigator'
import { NavigationItem } from '../Garden'
import {
  RouteConfig,
  RouteData,
  RouteInfo,
  RouteInterceptor,
  RouteHandler,
  RouteGraph,
} from './typing'
import { pathToRegexp, match } from 'path-to-regexp'
import stackHandler from './stack'
import tabsHandler from './tabs'
import drawerHandler from './drawer'

let routeDatas = new Map<string, RouteData>()
let interceptors = new Set<RouteInterceptor>()
let handlers = new Set<RouteHandler>([drawerHandler, tabsHandler, stackHandler])

const traverseHandlers: RouteHandler = (
  graph: RouteGraph,
  route: RouteInfo,
  next: RouteHandler,
) => {
  for (let handler of handlers.values()) {
    if (handler(graph, route, next)) {
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

function addRouteHandler(handler: RouteHandler) {
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

async function open(path: string, props: IndexType = {}, options: NavigationItem = {}) {
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
  if (!graphArray) {
    return
  }

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

  if (!traverseHandlers(graphArray[0], route, traverseHandlers)) {
    const navigator = await Navigator.current()
    navigator.closeMenu()
    const { moduleName, mode: routeMode, props } = route
    if (routeMode === 'present') {
      navigator.present(moduleName, props)
    } else if (routeMode === 'modal') {
      navigator.showModal(moduleName, props)
    } else {
      // default push
      navigator.push(moduleName, props)
    }
  }
}

function pathToRoute(
  path: string,
  props: IndexType,
  options: NavigationItem,
): RouteInfo | undefined {
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
  const pathParams = pathMatch ? pathMatch.params : {}
  return pathParams
}

function queryParams(queryString: string) {
  const queryParams = (queryString || '').split('&').reduce((result: IndexType, item: string) => {
    if (item !== '') {
      const nextResult = result || {}
      const [key, value] = item.split('=')
      nextResult[key] = value
      return nextResult
    }
    return result
  }, {})
  return queryParams
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
  addRouteHandler,
  registerRoute,
  open,
  pathToRoute,
}

export * from './typing'
export * from './drawer'
export * from './screen'
export * from './stack'
export * from './tabs'
