import pathToRegexp from 'path-to-regexp'
import { Linking } from 'react-native'
import { Navigator } from './Navigator'

export interface Route {
  moduleName: string
  sceneId: string
  mode: LayoutMode
}

export interface RouteInfo {
  mode: RouteMode
  moduleName: string
  dependencies: string[]
  props: object
}

export interface RouteConfig {
  dependency?: string
  path?: string
  pathRegexp?: RegExp
  moduleName?: string
  mode?: RouteMode
  paramNames?: (string | number)[]
}

type RouteMode = 'modal' | 'present' | 'push'
type LayoutMode = 'modal' | 'present' | 'normal'

export interface RouteGraph {
  layout: string
  sceneId: string
  mode: LayoutMode
  children?: RouteGraph[]
}

export interface StackGraph extends RouteGraph {
  layout: 'stack'
  sceneId: string
  mode: LayoutMode
  children: RouteGraph[]
}

export function isStackGraph(graph: RouteGraph): graph is StackGraph {
  return graph.layout === 'stack'
}

export interface TabsGraph extends RouteGraph {
  layout: 'tabs'
  sceneId: string
  selectedIndex: number
  mode: LayoutMode
  children: RouteGraph[]
}

export function isTabsGraph(graph: RouteGraph): graph is TabsGraph {
  return graph.layout === 'tabs'
}

export interface DrawerGraph extends RouteGraph {
  layout: 'drawer'
  sceneId: string
  mode: LayoutMode
  children: [RouteGraph, ScreenGraph]
}

export function isDrawerGraph(graph: RouteGraph): graph is DrawerGraph {
  return graph.layout === 'drawer'
}

export interface ScreenGraph extends RouteGraph {
  layout: 'screen'
  sceneId: string
  mode: LayoutMode
  moduleName: string
}

export function isScreenGraph(graph: RouteGraph): graph is ScreenGraph {
  return graph.layout === 'screen'
}

export type RouteInterceptor = (path: string) => boolean

export interface RouteParser {
  navigateTo(router: Router, graph: RouteGraph, route: RouteInfo): boolean
}

function routeDependencies(routeConfig: RouteConfig) {
  let dependencies: string[] = []
  let config: RouteConfig | undefined = routeConfig
  while (config && config.dependency) {
    dependencies.push(config.dependency)
    config = configs.get(config.dependency)
  }
  return dependencies.reverse()
}

const stackParser: RouteParser = {
  navigateTo(_: Router, graph: RouteGraph, route: RouteInfo) {
    if (!isStackGraph(graph)) {
      return false
    }

    const { children } = graph
    const { mode, moduleName, dependencies, props } = route

    if (mode === 'push') {
      let moduleNames = [...dependencies, moduleName]
      let index = -1

      for (let i = children.length - 1; i > -1; i--) {
        const child = children[i]
        if (isScreenGraph(child)) {
          index = moduleNames.indexOf(child.moduleName)
          if (index !== -1) {
            break
          }
        }
      }

      if (index !== -1) {
        let peddingModuleNames = moduleNames.slice(index + 1)
        const navigator = Navigator.get(children[children.length - 1].sceneId)
        if (peddingModuleNames.length === 0) {
          navigator.replace(moduleName, props)
        } else {
          for (let i = 0; i < peddingModuleNames.length; i++) {
            if (i === peddingModuleNames.length - 1) {
              navigator.push(moduleName, props)
            } else {
              navigator.push(peddingModuleNames[i], {}, {}, false)
            }
          }
        }
        return true
      }
    }

    return false
  },
}

const tabsParser: RouteParser = {
  navigateTo(router: Router, graph: RouteGraph, route: RouteInfo) {
    if (!isTabsGraph(graph)) {
      return false
    }

    const { children, selectedIndex } = graph
    const { dependencies, moduleName } = route

    for (let i = 0; i < children.length; i++) {
      const moduleNames: string[] = []
      extractModuleNames(children[i], moduleNames)
      if (
        moduleNames.indexOf(moduleName) !== -1 ||
        dependencies.some(value => moduleNames.indexOf(value) !== -1)
      ) {
        if (selectedIndex !== i) {
          const navigator = Navigator.get(children[i].sceneId)
          navigator.switchTab(i)
        }
        return router.navigateTo(children[i], route)
      }
    }
    return false
  },
}

function extractModuleNames(graph: RouteGraph, set: string[]) {
  if (isScreenGraph(graph)) {
    set.push(graph.moduleName)
  } else {
    const children = graph.children!
    for (let i = 0; i < children.length; i++) {
      extractModuleNames(children[i], set)
    }
  }
}

const drawerParser: RouteParser = {
  navigateTo(router: Router, graph: RouteGraph, route: RouteInfo) {
    if (!isDrawerGraph(graph)) {
      return false
    }

    const { moduleName, sceneId } = graph.children[1]
    if (moduleName === route.moduleName) {
      const navigator = Navigator.get(sceneId)
      navigator.openMenu()
      return true
    } else {
      let result = router.navigateTo(graph.children[0], route)
      if (result) {
        const navigator = Navigator.get(sceneId)
        navigator.closeMenu()
      }
      return result
    }
  },
}

let configs = new Map<string, RouteConfig>()
let interceptors = new Set<RouteInterceptor>()
let active = 0
let parsers = new Set<RouteParser>([drawerParser, tabsParser, stackParser])

class Router {
  private hasHandleInitialURL: boolean
  private uriPrefix?: string
  constructor() {
    this.routeEventHandler = this.routeEventHandler.bind(this)
    this.hasHandleInitialURL = false
  }

  clear() {
    active = 0
    configs.clear()
  }

  addRouteConfig(moduleName: string, routeConfig: RouteConfig) {
    if (routeConfig.path) {
      routeConfig.pathRegexp = pathToRegexp(routeConfig.path)
      let params = pathToRegexp.parse(routeConfig.path).slice(1)
      routeConfig.paramNames = []
      for (let i = 0; i < params.length; i++) {
        const key: pathToRegexp.Key = params[i] as pathToRegexp.Key
        routeConfig.paramNames.push(key.name)
      }
    }
    routeConfig.moduleName = moduleName
    routeConfig.mode = routeConfig.mode || 'push'
    configs.set(moduleName, routeConfig)
  }

  registerInterceptor(func: RouteInterceptor) {
    interceptors.add(func)
  }

  unregisterInterceptor(func: RouteInterceptor) {
    interceptors.delete(func)
  }

  registerParser(parser: RouteParser) {
    parsers.add(parser)
  }

  pathToRoute(path: string): RouteInfo | null {
    for (const routeConfig of configs.values()) {
      if (!routeConfig.pathRegexp) {
        continue
      }
      const match = routeConfig.pathRegexp.exec(path)
      if (match) {
        const moduleName = routeConfig.moduleName

        if (!moduleName) {
          return null
        }

        const props: any = {}
        const names = routeConfig.paramNames
        if (names) {
          for (let i = 0; i < names.length; i++) {
            props[names[i]] = match[i + 1]
          }
        }

        const dependencies = routeDependencies(routeConfig)
        const mode = routeConfig.mode || 'push'
        return { moduleName, props, dependencies, mode }
      }
    }
    return null
  }

  navigateTo(graph: RouteGraph, route: RouteInfo) {
    for (let parser of parsers.values()) {
      if (parser.navigateTo(this, graph, route)) {
        return true
      }
    }
    return false
  }

  async open(path: string) {
    if (!path) {
      return
    }

    let intercepted = false
    for (let interceptor of interceptors.values()) {
      intercepted = interceptor(path)
      if (intercepted) {
        return
      }
    }

    const route = this.pathToRoute(path)
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

    if (!this.navigateTo(graphArray[0], route)) {
      const navigator = await Navigator.current()
      navigator.closeMenu()
      const { moduleName, mode: routeMode, props } = route
      if (routeMode === 'present') {
        navigator.present(moduleName, 0, props)
      } else if (routeMode === 'modal') {
        navigator.showModal(moduleName, 0, props)
      } else {
        // default push
        navigator.push(moduleName, props)
      }
    }
  }

  activate(uriPrefix: string) {
    if (!uriPrefix) {
      throw new Error('must pass `uriPrefix` when activate router.')
    }
    if (active === 0) {
      this.uriPrefix = uriPrefix
      if (!this.hasHandleInitialURL) {
        this.hasHandleInitialURL = true
        Linking.getInitialURL()
          .then(url => {
            if (url) {
              const path = url.replace(this.uriPrefix!, '')
              this.open(path)
            }
          })
          .catch(err => console.error('An error occurred', err))
      }
      Linking.addEventListener('url', this.routeEventHandler)
    }
    active++
  }

  inactivate() {
    active--
    if (active === 0) {
      Linking.removeEventListener('url', this.routeEventHandler)
    }

    if (active < 0) {
      active = 0
    }
  }

  private routeEventHandler(event: { url: string }): void {
    console.info(`deeplink:${event.url}`)
    const path = event.url.replace(this.uriPrefix!, '')
    this.open(path)
  }
}

const router = new Router()
export { router }
