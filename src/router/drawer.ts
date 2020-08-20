import { RouteGraph, LayoutMode, RouteInfo, RouteHandler } from './typing'
import { ScreenGraph } from './screen'
import { Navigator } from '../Navigator'

export interface DrawerGraph extends RouteGraph {
  layout: 'drawer'
  sceneId: string
  mode: LayoutMode
  children: [RouteGraph, ScreenGraph]
}

export function isDrawerGraph(graph: RouteGraph): graph is DrawerGraph {
  return graph.layout === 'drawer'
}

const handler: RouteHandler = (graph: RouteGraph, route: RouteInfo, next: RouteHandler) => {
  if (!isDrawerGraph(graph)) {
    return false
  }

  const { moduleName, sceneId } = graph.children[1]
  if (moduleName === route.moduleName) {
    const navigator = Navigator.get(sceneId)
    navigator.openMenu()
    return true
  } else {
    let result = next(graph.children[0], route, next)
    if (result) {
      const navigator = Navigator.get(sceneId)
      navigator.closeMenu()
    }
    return result
  }
}

export default handler
