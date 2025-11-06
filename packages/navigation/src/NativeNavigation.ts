import { TurboModuleRegistry } from 'react-native';
import type { CodegenTypes, TurboModule } from 'react-native';

type Error = {
	code: string;
	message: string;
};

export type LayoutMode = 'modal' | 'present' | 'normal';

export interface Route {
	sceneId: string;
	moduleName: string;
	mode: LayoutMode;
	presentingId: string | null;
	requestCode: number;
}

export interface RouteGraph {
	layout: string;
	sceneId: string;
	mode: LayoutMode;
	children?: RouteGraph[];
}

export type RouteMode = 'modal' | 'present' | 'push';

export interface RouteConfig {
	path?: string;
	dependency?: string;
	mode?: RouteMode;
}

export type ResultType = {} | null;

export interface Spec extends TurboModule {
	getConstants: () => {
		RESULT_OK: number;
		RESULT_CANCEL: number;
		RESULT_BLOCK: number;
	};

	startRegisterReactComponent: () => void;
	endRegisterReactComponent: () => void;
	registerReactComponent: (appKey: string, options: CodegenTypes.UnsafeObject) => void;
	signalFirstRenderComplete: (sceneId: string) => void;
	setRoot: (
		layout: CodegenTypes.UnsafeObject,
		sticky: boolean,
		callback: (error: Error | null, result: boolean) => void,
	) => void;
	setResult: (sceneId: string, resultCode: number, data: CodegenTypes.UnsafeObject) => void;
	dispatch: (
		sceneId: string,
		action: string,
		params: CodegenTypes.UnsafeObject,
		callback: (error: Error | null, result: boolean) => void,
	) => void;
	currentTab: (sceneId: string, callback: (error: Error | null, index: number) => void) => void;
	isStackRoot: (
		sceneId: string,
		callback: (error: Error | null, result: boolean) => void,
	) => void;
	findSceneIdByModuleName: (
		moduleName: string,
		callback: (error: Error | null, sceneId: string | null) => void,
	) => void;
	currentRoute: (callback: (error: Error | null, route: Route) => void) => void;
	routeGraph: (callback: (error: Error | null, graph: RouteGraph[]) => void) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('HBDNativeNavigation');
