import { ScreenGraph, isScreenGraph, isTargetLocateIn } from './screen';
import { LayoutMode, RouteGraph, RouteHandler, RouteInfo } from '../Route';
import Navigation from '../Navigation';

export interface StackGraph extends RouteGraph {
	layout: 'stack';
	sceneId: string;
	mode: LayoutMode;
	children: RouteGraph[];
}

export function isStackGraph(graph: RouteGraph): graph is StackGraph {
	return graph.layout === 'stack';
}

export class StackRouteHandler implements RouteHandler {
	async process(graph: RouteGraph, target: RouteInfo): Promise<[boolean, RouteGraph | null]> {
		if (!isStackGraph(graph)) {
			throw new Error(`${graph} is Not a StackGraph`);
		}

		const { children } = graph;

		for (let i = children.length - 1; i > -1; i--) {
			const childGraph = children[i];
			if (isTargetLocateIn(childGraph, target)) {
				if (isScreenGraph(childGraph)) {
					this.navigateTo(childGraph, target);
					return [true, null];
				}

				await this.popToIfNeeded(childGraph, i === children.length - 1);
				return [true, childGraph];
			}
		}

		return [false, graph];
	}

	private async popToIfNeeded(childGraph: RouteGraph, isLastChildAtStack: boolean) {
		if (!isLastChildAtStack) {
			await Navigation.dispatch(childGraph.sceneId, 'popTo', {
				moduleName: childGraph.sceneId,
			});
		}
	}

	private navigateTo(childGraph: ScreenGraph, target: RouteInfo) {
		const { moduleName, dependencies, props } = target;
		const expectations = [...dependencies, moduleName];
		const index = expectations.findIndex(name => name === childGraph.moduleName);
		const pendings = expectations.slice(index + 1);
		console.log('pendings', pendings, 'moduleName', childGraph.moduleName);
		const sceneId = childGraph.sceneId;

		const moduleExisting = pendings.length === 0;

		if (moduleExisting) {
			if (JSON.stringify(props) === '{}') {
				Navigation.dispatch(sceneId, 'popTo', {
					moduleName,
					from: childGraph.moduleName,
					to: moduleName,
				});
			} else {
				Navigation.dispatch(sceneId, 'redirectTo', {
					moduleName,
					from: childGraph.moduleName,
					to: moduleName,
					props,
				});
			}
		} else {
			for (let i = 0; i < pendings.length; i++) {
				const isLast = i === pendings.length - 1;
				if (isLast) {
					Navigation.dispatch(sceneId, 'push', {
						moduleName,
						from: childGraph.moduleName,
						to: moduleName,
						props,
					});
				} else {
					Navigation.dispatch(sceneId, 'push', {
						moduleName: pendings[i],
						from: childGraph.moduleName,
						to: pendings[i],
					});
				}
			}
		}
	}
}
