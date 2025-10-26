import type { Route, RouteGraph, RouteConfig, ResultType } from './NativeNavigation';
import NativeNavigation from './NativeNavigation';

function getConstants() {
	return NativeNavigation.getConstants();
}

function startRegisterReactComponent() {
	NativeNavigation.startRegisterReactComponent();
}

function endRegisterReactComponent() {
	NativeNavigation.endRegisterReactComponent();
}

function registerReactComponent(appKey: string, options: RouteConfig) {
	NativeNavigation.registerReactComponent(appKey, options);
}

function signalFirstRenderComplete(sceneId: string) {
	NativeNavigation.signalFirstRenderComplete(sceneId);
}

function setResult<T extends ResultType>(sceneId: string, resultCode: number, data: T) {
	NativeNavigation.setResult(sceneId, resultCode, data);
}

function setRoot(layout: object, sticky: boolean) {
	return new Promise<boolean>(resolve => {
		NativeNavigation.setRoot(layout, sticky, (_, success) => {
			resolve(success);
		});
	});
}

function dispatch(sceneId: string, action: string, params: object) {
	return new Promise<boolean>(resolve => {
		NativeNavigation.dispatch(sceneId, action, params, (_, result) => {
			resolve(result);
		});
	});
}

function currentTab(sceneId: string) {
	return new Promise<number>(resolve => {
		NativeNavigation.currentTab(sceneId, (_, index) => {
			resolve(index);
		});
	});
}

function isStackRoot(sceneId: string) {
	return new Promise<boolean>(resolve => {
		NativeNavigation.isStackRoot(sceneId, (_, result) => {
			resolve(result);
		});
	});
}

function findSceneIdByModuleName(moduleName: string) {
	return new Promise<string | null>(resolve => {
		NativeNavigation.findSceneIdByModuleName(moduleName, (_, sceneId) => {
			resolve(sceneId);
		});
	});
}

function currentRoute() {
	return new Promise<Route>(resolve => {
		NativeNavigation.currentRoute((_, route) => {
			resolve(route);
		});
	});
}

function routeGraph() {
	return new Promise<RouteGraph[]>(resolve => {
		NativeNavigation.routeGraph((_, graph) => {
			resolve(graph);
		});
	});
}

export default {
	getConstants,
	startRegisterReactComponent,
	endRegisterReactComponent,
	registerReactComponent,
	signalFirstRenderComplete,
	setResult,
	setRoot,
	dispatch,
	currentTab,
	isStackRoot,
	findSceneIdByModuleName,
	currentRoute,
	routeGraph,
};
