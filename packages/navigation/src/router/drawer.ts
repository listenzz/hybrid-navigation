import { ScreenGraph, isTargetLocateIn } from './screen';
import { LayoutMode, RouteGraph, RouteHandler, RouteInfo } from '../Route';
import Navigation from '../Navigation';

export interface DrawerGraph extends RouteGraph {
  layout: 'drawer'
  sceneId: string
  mode: LayoutMode
  children: [RouteGraph, ScreenGraph]
}

export function isDrawerGraph(graph: RouteGraph): graph is DrawerGraph {
  return graph.layout === 'drawer';
}

export class DrawerRouteHandler implements RouteHandler {
  async process(graph: RouteGraph, target: RouteInfo): Promise<[boolean, RouteGraph | null]> {
    if (!isDrawerGraph(graph)) {
      throw new Error(`${graph} is Not a DrawerGraph`);
    }

    const { children } = graph;

    const { moduleName, sceneId } = children[1];
    if (moduleName === target.moduleName) {
      await Navigation.dispatch(sceneId, 'openMenu');
      return [true, null];
    }

    if (isTargetLocateIn(children[0], target)) {
      Navigation.dispatch(sceneId, 'closeMenu', { from: moduleName });
      return [true, children[0]];
    }

    return [false, graph];
  }
}
