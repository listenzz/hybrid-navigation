import { LayoutMode, RouteGraph, RouteHandler, RouteInfo } from '../Route';

export interface ScreenGraph extends RouteGraph {
  layout: 'screen'
  sceneId: string
  mode: LayoutMode
  moduleName: string
}

export function isScreenGraph(graph: RouteGraph): graph is ScreenGraph {
  return graph.layout === 'screen';
}

function extractModuleNames(graph: RouteGraph, set: string[]) {
  if (isScreenGraph(graph)) {
    set.push(graph.moduleName);
  } else {
    const children = graph.children!;
    for (let i = 0; i < children.length; i++) {
      extractModuleNames(children[i], set);
    }
  }
}

export function isTargetLocateIn(graph: RouteGraph, target: RouteInfo) {
  const existings: string[] = [];
  extractModuleNames(graph, existings);
  const { dependencies, moduleName } = target;
  const expectations = [...dependencies, moduleName];
  return expectations.some(name => existings.includes(name));
}

export class ScreenRouteHandler implements RouteHandler {
  process(graph: RouteGraph, target: RouteInfo): Promise<[boolean, RouteGraph | null]> {
    if (!isScreenGraph(graph)) {
      throw new Error(`${graph} is Not a ScreenGraph`);
    }

    if (graph.moduleName === target.moduleName) {
      return Promise.resolve([true, null]);
    }

    return Promise.resolve([false, graph]);
  }
}
