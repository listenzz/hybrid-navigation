import { RouteGraph, LayoutMode, RouteInfo, RouteHandler } from './typing'
import { isScreenGraph } from './screen'
import { Navigator } from '../Navigator'

export interface StackGraph extends RouteGraph {
  layout: 'stack'
  sceneId: string
  mode: LayoutMode
  children: RouteGraph[]
}

export function isStackGraph(graph: RouteGraph): graph is StackGraph {
  return graph.layout === 'stack'
}

export async function stackRouteHandler(graph: RouteGraph, route: RouteInfo, next: RouteHandler) {
  if (!isStackGraph(graph)) {
    return false
  }

  const { mode, moduleName, dependencies, props } = route

  if (mode !== 'push') {
    return false
  }

  const { children } = graph
  const expectedModuleNames = [...dependencies, moduleName]
  let expectedIndex = -1
  let childIndex = -1

  for (let i = children.length - 1; i > -1; i--) {
    const existingModuleNames: string[] = []
    extractModuleNames(children[i], existingModuleNames)
    expectedIndex = expectedModuleNames.findIndex(name => existingModuleNames.includes(name))
    if (expectedIndex !== -1) {
      childIndex = i
      break
    }
  }

  if (expectedIndex !== -1) {
    if (!isScreenGraph(children[childIndex])) {
      await next(children[childIndex], route, next)
    }

    let pendingModuleNames = expectedModuleNames.slice(expectedIndex + 1)
    const navigator = Navigator.of(children[children.length - 1].sceneId)

    if (pendingModuleNames.length === 0) {
      if (JSON.stringify(props) === '{}') {
        await navigator.popTo(moduleName)
      } else {
        navigator.redirectTo(moduleName, props)
      }
    } else {
      for (let i = 0; i < pendingModuleNames.length; i++) {
        if (i === pendingModuleNames.length - 1) {
          navigator.push(moduleName, props)
        } else {
          navigator.push(pendingModuleNames[i], {}, {})
        }
      }
    }
    return true
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
