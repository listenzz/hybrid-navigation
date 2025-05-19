import type React from 'react';
import {AppRegistry, ComponentProvider} from 'react-native';

import type {
	BarButtonItem,
	DefaultOptions,
	NavigationOption,
	TabBarStyle,
	TabItemInfo,
	TitleItem,
} from './Options';
import type {BuildInLayout, Layout, Route, RouteGraph, RouteConfig} from './Route';

import BarButtonEventHandler from './handler/BarButtonEventHandler';
import LayoutCommandHandler from './handler/LayoutCommandHandler';
import DispatchCommandHandler from './handler/DispatchCommandHandler';
import ResultEventHandler, {ResultType} from './handler/ResultEventHandler';
import VisibilityEventHandler, {
	GlobalVisibilityEventListener,
	VisibilityEventListener,
} from './handler/VisibilityEventHandler';

import Event from './Event';
import GardenModule from './GardenModule';
import NavigationModule from './NavigationModule';

export type {ResultType} from './handler/ResultEventHandler';
import type {DispatchParams, NavigationInterceptor} from './handler/DispatchCommandHandler';
export type {DispatchParams, NavigationInterceptor} from './handler/DispatchCommandHandler';

type BarButtonClickEventListener = (sceneId: string, value: Function) => void;

type Nullable<T> = {
	[P in keyof T]: T[P] extends T[P] | undefined ? T[P] | null : T[P];
};

export const {RESULT_CANCEL, RESULT_OK, RESULT_BLOCK} = NavigationModule.getConstants();

export type NavigationSubscription = {
	remove: () => void;
};

export type HOC = (WrappedComponent: React.ComponentType<any>) => React.ComponentType<any>;

export interface Navigation {
	startRegisterComponent(hoc?: HOC): void;
	endRegisterComponent(): void;
	registerComponent(
		appKey: string,
		getComponentFunc: ComponentProvider,
		routeConfig?: RouteConfig,
	): void;

	routeConfigs(): Map<string, RouteConfig>;
	setNavigationComponentWrap(wrap: (moduleName: string) => HOC): void;
	addGlobalVisibilityEventListener(
		listener: GlobalVisibilityEventListener,
	): NavigationSubscription;
	addVisibilityEventListener(
		sceneId: string,
		listener: VisibilityEventListener,
	): NavigationSubscription;
	dispatch(sceneId: string, action: string, params?: DispatchParams): Promise<boolean>;
	setInterceptor(interceptor: NavigationInterceptor): void;
	setResult<T extends ResultType>(sceneId: string, resultCode: number, data?: T): void;
	result<T extends ResultType>(sceneId: string, resultCode: number): Promise<[number, T]>;
	unmount(sceneId: string): void;
	setRoot(layout: BuildInLayout | Layout, sticky?: boolean): Promise<boolean>;
	setRootLayoutUpdateListener(willSetRoot?: () => void, didSetRoot?: () => void): void;
	currentTab(sceneId: string): Promise<number>;
	findSceneIdByModuleName(moduleName: string): Promise<string | null>;
	isStackRoot(sceneId: string): Promise<boolean>;
	signalFirstRenderComplete(sceneId: string): void;
	currentRoute(): Promise<Route>;
	routeGraph(): Promise<RouteGraph[]>;
	setDefaultOptions(options: DefaultOptions): void;
	setLeftBarButtonItem(sceneId: string, buttonItem: Nullable<BarButtonItem> | null): void;
	setRightBarButtonItem(sceneId: string, buttonItem: Nullable<BarButtonItem> | null): void;
	setLeftBarButtonItems(
		sceneId: string,
		buttonItems: Array<Nullable<BarButtonItem>> | null,
	): void;
	setRightBarButtonItems(
		sceneId: string,
		buttonItems: Array<Nullable<BarButtonItem>> | null,
	): void;
	setTitleItem(sceneId: string, titleItem: TitleItem): void;
	updateOptions(sceneId: string, options: NavigationOption): void;
	updateTabBar(sceneId: string, options: TabBarStyle): void;
	setTabItem(sceneId: string, item: TabItemInfo | TabItemInfo[]): void;
	setMenuInteractive(sceneId: string, enabled: boolean): void;
	setBarButtonClickEventListener(listener: BarButtonClickEventListener): void;
}

class NavigationImpl implements Navigation {
	private dispatchHandler = new DispatchCommandHandler();
	private resultHandler = new ResultEventHandler();
	private buttonHandler = new BarButtonEventHandler();
	private layoutHandler = new LayoutCommandHandler();
	private visibilityHandler = new VisibilityEventHandler();

	constructor() {
		this.handleTabSwitch();
		this.layoutHandler.handleRootLayoutChange();
		this.visibilityHandler.handleComponentVisibility();
		this.resultHandler.handleComponentResult();
	}

	private wrap?: (moduleName: string) => HOC;
	private hoc?: HOC;
	private registerEnded = false;

	startRegisterComponent(hoc?: HOC) {
		this.hoc = hoc;
		this.registerEnded = false;
		NavigationModule.startRegisterReactComponent();
	}

	endRegisterComponent() {
		if (this.registerEnded) {
			console.warn("Please don't call ReactRegistry#endRegisterComponent multiple times.");
			return;
		}
		this.registerEnded = true;
		NavigationModule.endRegisterReactComponent();
	}

	registerComponent(
		appKey: string,
		getComponentFunc: ComponentProvider,
		routeConfig?: RouteConfig,
	) {
		if (routeConfig) {
			this.registerRoute(appKey, routeConfig);
		}

		let WrappedComponent = getComponentFunc();
		if (this.hoc) {
			WrappedComponent = this.hoc(WrappedComponent);
		}

		// build static options
		let options: object =
			this.bindBarButtonClickEvent('permanent', (WrappedComponent as any).navigationItem) ||
			{};
		NavigationModule.registerReactComponent(appKey, options);

		let RootComponent = this.wrap!(appKey)(WrappedComponent);
		AppRegistry.registerComponent(appKey, () => RootComponent);
	}

	private _routeConfigs = new Map<string, RouteConfig>();

	private registerRoute(moduleName: string, route: RouteConfig) {
		this._routeConfigs.set(moduleName, route);
	}

	routeConfigs() {
		return this._routeConfigs;
	}

	setNavigationComponentWrap(wrap: (moduleName: string) => HOC) {
		this.wrap = wrap;
	}

	addGlobalVisibilityEventListener(
		listener: GlobalVisibilityEventListener,
	): NavigationSubscription {
		this.visibilityHandler.addGlobalVisibilityEventListener(listener);
		return {
			remove: () => this.visibilityHandler.removeGlobalVisibilityEventListener(listener),
		};
	}

	addVisibilityEventListener(
		sceneId: string,
		listener: VisibilityEventListener,
	): NavigationSubscription {
		this.visibilityHandler.addVisibilityEventListener(sceneId, listener);
		return {
			remove: () => this.visibilityHandler.removeVisibilityEventListener(sceneId, listener),
		};
	}

	dispatch(sceneId: string, action: string, params: DispatchParams = {}) {
		return this.dispatchHandler.dispatch(sceneId, action, params);
	}

	private handleTabSwitch() {
		Event.listenTabSwitch((sceneId: string, from: number, to: number) => {
			this.dispatch(sceneId, 'switchTab', {from, to});
		});
	}

	setInterceptor(interceptor: NavigationInterceptor) {
		this.dispatchHandler.setInterceptor(interceptor);
	}

	setResult = <T extends ResultType>(
		sceneId: string,
		resultCode: number,
		data: T = null as T,
	): void => {
		if (resultCode < RESULT_OK) {
			console.warn(
				'`resultCode` can only be `RESULT_OK`, `RESULT_CANCEL` or an integer greater than 0.',
			);
		}
		NavigationModule.setResult(sceneId, resultCode, data);
	};

	result<T extends ResultType>(sceneId: string, resultCode: number) {
		return this.resultHandler.waitResult<T>(sceneId, resultCode);
	}

	unmount(sceneId: string) {
		this.resultHandler.invalidateResultEventListener(sceneId);
		this.buttonHandler.unbindBarButtonClickEvent(sceneId);
	}

	setRoot(layout: BuildInLayout | Layout, sticky = false) {
		return this.layoutHandler.setRoot(layout, sticky);
	}

	setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
		this.layoutHandler.setRootLayoutUpdateListener(willSetRoot, didSetRoot);
	}

	currentTab(sceneId: string) {
		return NavigationModule.currentTab(sceneId);
	}

	findSceneIdByModuleName(moduleName: string) {
		return NavigationModule.findSceneIdByModuleName(moduleName);
	}

	isStackRoot(sceneId: string) {
		return NavigationModule.isStackRoot(sceneId);
	}

	signalFirstRenderComplete(sceneId: string) {
		NavigationModule.signalFirstRenderComplete(sceneId);
	}

	currentRoute(): Promise<Route> {
		return NavigationModule.currentRoute();
	}

	routeGraph(): Promise<RouteGraph[]> {
		return NavigationModule.routeGraph();
	}

	setDefaultOptions(options: DefaultOptions) {
		GardenModule.setStyle(options);
	}

	setLeftBarButtonItem(sceneId: string, buttonItem: Nullable<BarButtonItem> | null) {
		const options = this.bindBarButtonClickEvent(sceneId, buttonItem);
		GardenModule.setLeftBarButtonItem(sceneId, options);
	}

	setRightBarButtonItem(sceneId: string, buttonItem: Nullable<BarButtonItem> | null) {
		const options = this.bindBarButtonClickEvent(sceneId, buttonItem);
		GardenModule.setRightBarButtonItem(sceneId, options);
	}

	setLeftBarButtonItems(sceneId: string, buttonItems: Array<Nullable<BarButtonItem>> | null) {
		const options = this.bindBarButtonClickEvent(sceneId, buttonItems);
		GardenModule.setLeftBarButtonItems(sceneId, options);
	}

	setRightBarButtonItems(sceneId: string, buttonItems: Array<Nullable<BarButtonItem>> | null) {
		const options = this.bindBarButtonClickEvent(sceneId, buttonItems);
		GardenModule.setRightBarButtonItems(sceneId, options);
	}

	setTitleItem(sceneId: string, titleItem: TitleItem) {
		GardenModule.setTitleItem(sceneId, titleItem);
	}

	updateOptions(sceneId: string, options: NavigationOption) {
		GardenModule.updateOptions(sceneId, options);
	}

	updateTabBar(sceneId: string, options: TabBarStyle) {
		GardenModule.updateTabBar(sceneId, options);
	}

	setTabItem(sceneId: string, item: TabItemInfo | TabItemInfo[]) {
		if (!Array.isArray(item)) {
			item = [item];
		}
		GardenModule.setTabItem(sceneId, item);
	}

	setMenuInteractive(sceneId: string, enabled: boolean) {
		GardenModule.setMenuInteractive(sceneId, enabled);
	}

	setBarButtonClickEventListener(listener: BarButtonClickEventListener) {
		this.buttonHandler.setBarButtonClickEventListener(listener);
	}

	private bindBarButtonClickEvent(
		sceneId: string,
		item: object | null | undefined,
	): object | null {
		return this.buttonHandler.bindBarButtonClickEvent(sceneId, item);
	}
}

export default new NavigationImpl() as Navigation;
