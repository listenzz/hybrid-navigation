import { isTargetLocateIn } from './screen';
import { LayoutMode, RouteGraph, RouteHandler, RouteInfo } from '../Route';
import Navigation from '../Navigation';

export interface TabsGraph extends RouteGraph {
	layout: 'tabs';
	sceneId: string;
	selectedIndex: number;
	mode: LayoutMode;
	children: RouteGraph[];
}

export function isTabsGraph(graph: RouteGraph): graph is TabsGraph {
	return graph.layout === 'tabs';
}
export class TabsRouteHandler implements RouteHandler {
	async process(graph: RouteGraph, target: RouteInfo): Promise<[boolean, RouteGraph]> {
		if (!isTabsGraph(graph)) {
			throw new Error(`${graph} is NOT a TabsGraph`);
		}

		const { children, selectedIndex } = graph;

		for (let i = 0; i < children.length; i++) {
			if (isTargetLocateIn(children[i], target)) {
				if (selectedIndex !== i) {
					await Navigation.dispatch(children[selectedIndex].sceneId, 'switchTab', {
						from: selectedIndex,
						to: i,
						popToRoot: true,
					});
				}
				return [true, children[i]];
			}
		}

		return [false, graph];
	}
}
