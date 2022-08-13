import { LayoutMode, RouteGraph } from '../Route'

export interface ScreenGraph extends RouteGraph {
  layout: 'screen'
  sceneId: string
  mode: LayoutMode
  moduleName: string
}

export function isScreenGraph(graph: RouteGraph): graph is ScreenGraph {
  return graph.layout === 'screen'
}
