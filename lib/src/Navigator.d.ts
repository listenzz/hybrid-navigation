import { NavigationItem } from './Garden';
import { Route, RouteGraph } from './router';
interface Extras {
    sceneId: string;
    index?: number;
}
interface Params {
    animated?: boolean;
    moduleName?: string;
    layout?: Layout;
    index?: number;
    popToRoot?: boolean;
    targetId?: string;
    requestCode?: number;
    props?: {
        [x: string]: any;
    };
    options?: NavigationItem;
}
export declare type NavigationInterceptor = (action: string, from?: string, to?: string, extras?: Extras) => boolean;
export interface Layout {
    [x: string]: {};
}
export interface Screen extends Layout {
    screen: {
        moduleName: string;
        props?: {
            [x: string]: any;
        };
        options?: NavigationItem;
    };
}
export interface Stack extends Layout {
    stack: {
        children: Layout[];
        options?: {};
    };
}
export interface Tabs extends Layout {
    tabs: {
        children: Layout[];
        options?: {
            selectedIndex?: number;
            tabBarModuleName?: string;
            sizeIndeterminate?: boolean;
        };
    };
}
export interface Drawer extends Layout {
    drawer: {
        children: [Layout, Layout];
        options?: {
            maxDrawerWidth?: number;
            minDrawerMargin?: number;
            menuInteractive?: boolean;
        };
    };
}
export declare class Navigator {
    sceneId: string;
    moduleName?: string | undefined;
    static RESULT_OK: -1;
    static RESULT_CANCEL: 0;
    static get(sceneId: string): Navigator;
    static current(): Promise<Navigator | null>;
    static currentRoute(): Promise<Route | null>;
    static routeGraph(): Promise<RouteGraph[] | null>;
    static setRoot(layout: Layout, sticky?: boolean): void;
    static setRootLayoutUpdateListener(willSetRoot?: () => void, didSetRoot?: () => void): void;
    static dispatch(sceneId: string, action: string, params?: Params): void;
    static setInterceptor(interceptor: NavigationInterceptor): void;
    constructor(sceneId: string, moduleName?: string | undefined);
    state: {
        params: {
            readonly [x: string]: any;
        };
    };
    setParams(params: {
        [x: string]: any;
    }): void;
    dispatch(action: string, params?: Params): void;
    push(moduleName: string, props?: {
        [x: string]: any;
    }, options?: NavigationItem, animated?: boolean): void;
    pushLayout(layout: Layout, animated?: boolean): void;
    pop(animated?: boolean): void;
    popTo(sceneId: string, animated?: boolean): void;
    popToRoot(animated?: boolean): void;
    replace(moduleName: string, props?: {
        [x: string]: any;
    }, options?: NavigationItem): void;
    replaceToRoot(moduleName: string, props?: {
        [x: string]: any;
    }, options?: NavigationItem): void;
    isRoot(): Promise<boolean>;
    isStackRoot(): Promise<boolean>;
    present(moduleName: string, requestCode?: number, props?: {
        [x: string]: any;
    }, options?: NavigationItem, animated?: boolean): void;
    presentLayout(layout: Layout, requestCode?: number, animated?: boolean): void;
    dismiss(animated?: boolean): void;
    showModal(moduleName: string, requestCode?: number, props?: {
        [x: string]: any;
    }, options?: NavigationItem): void;
    showModalLayout(layout: Layout, requestCode?: number): void;
    hideModal(): void;
    setResult(resultCode: number, data?: {
        [x: string]: any;
    }): void;
    switchTab(index: number, popToRoot?: boolean): void;
    toggleMenu(): void;
    openMenu(): void;
    closeMenu(): void;
    signalFirstRenderComplete(): void;
}
export {};
