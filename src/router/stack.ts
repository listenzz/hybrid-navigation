import { RouteGraph, LayoutMode, RouteHandler, RouteInfo } from './typing'
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

const handler: RouteHandler = (graph: RouteGraph, route: RouteInfo) => {
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
        navigator.redirectTo(moduleName, props)
      } else {
        for (let i = 0; i < peddingModuleNames.length; i++) {
          if (i === peddingModuleNames.length - 1) {
            navigator.push(moduleName, props)
          } else {
            navigator.push(peddingModuleNames[i], {}, {})
          }
        }
      }
      return true
    }
  }

  return false
}

export default handler
