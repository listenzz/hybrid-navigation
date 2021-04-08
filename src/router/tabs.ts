import { RouteGraph, LayoutMode, RouteHandler, RouteInfo } from './typing'
import { Navigator } from '../Navigator'
import { isScreenGraph } from './screen'

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

const handler: RouteHandler = (graph: RouteGraph, route: RouteInfo, next: RouteHandler) => {
  if (!isTabsGraph(graph)) {
    return false
  }

  const { children, selectedIndex } = graph
  const { dependencies, moduleName } = route

  for (let i = 0; i < children.length; i++) {
    const moduleNames: string[] = []
    extractModuleNames(children[i], moduleNames)
    if (moduleNames.indexOf(moduleName) !== -1 || dependencies.some(value => moduleNames.indexOf(value) !== -1)) {
      if (selectedIndex !== i) {
        const navigator = Navigator.of(children[i].sceneId)
        navigator.switchTab(i)
      }
      return next(children[i], route, next)
    }
  }
  return false
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

export default handler
