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

export async function tabsRouteHandler(graph: RouteGraph, route: RouteInfo, next: RouteHandler) {
  if (!isTabsGraph(graph)) {
    return false
  }

  const { children, selectedIndex } = graph
  const { dependencies, moduleName } = route
  const expectedModuleNames = [...dependencies, moduleName]

  for (let i = 0; i < children.length; i++) {
    const existingModuleNames: string[] = []
    extractModuleNames(children[i], existingModuleNames)
    if (expectedModuleNames.some(name => existingModuleNames.includes(name))) {
      if (selectedIndex !== i) {
        const navigator = Navigator.of(children[i].sceneId)
        await navigator.switchTab(i, true)
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
