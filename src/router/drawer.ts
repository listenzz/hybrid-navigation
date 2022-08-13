import { ScreenGraph } from './screen'
import { Navigator } from '../Navigator'
import { LayoutMode, RouteGraph, RouteHandler, RouteInfo } from '../Route'

export interface DrawerGraph extends RouteGraph {
  layout: 'drawer'
  sceneId: string
  mode: LayoutMode
  children: [RouteGraph, ScreenGraph]
}

export function isDrawerGraph(graph: RouteGraph): graph is DrawerGraph {
  return graph.layout === 'drawer'
}

export async function drawerRouteHandler(graph: RouteGraph, route: RouteInfo, next: RouteHandler) {
  if (!isDrawerGraph(graph)) {
    return false
  }

  const { moduleName, sceneId } = graph.children[1]
  if (moduleName === route.moduleName) {
    const navigator = Navigator.of(sceneId)
    navigator.openMenu()
    return true
  } else {
    let result = await next(graph.children[0], route, next)
    if (result) {
      const navigator = Navigator.of(sceneId)
      navigator.closeMenu()
    }
    return result
  }
}
