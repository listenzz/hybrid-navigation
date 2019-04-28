export interface Route {
    moduleName: string;
    sceneId: string;
    mode: LayoutMode;
}
export interface RouteInfo {
    mode: RouteMode;
    moduleName: string;
    dependencies: string[];
    props: object;
}
export interface RouteConfig {
    dependency?: string;
    path?: string;
    pathRegexp?: RegExp;
    moduleName?: string;
    mode?: RouteMode;
    paramNames?: (string | number)[];
}
declare type RouteMode = 'modal' | 'present' | 'push';
declare type LayoutMode = 'modal' | 'present' | 'normal';
export interface RouteGraph {
    layout: string;
    sceneId: string;
    mode: LayoutMode;
}
export interface StackGraph extends RouteGraph {
    layout: 'stack';
    sceneId: string;
    mode: LayoutMode;
    children: ScreenGraph[];
}
export interface TabsGraph extends RouteGraph {
    layout: 'tabs';
    sceneId: string;
    selectedIndex: number;
    mode: LayoutMode;
    children: RouteGraph[];
}
export interface DrawerGraph extends RouteGraph {
    layout: 'drawer';
    sceneId: string;
    mode: LayoutMode;
    children: [RouteGraph, ScreenGraph];
}
export interface ScreenGraph extends RouteGraph {
    layout: 'screen';
    sceneId: string;
    mode: LayoutMode;
    moduleName: string;
}
export declare type RouteInterceptor = (path: string) => boolean;
export interface RouteParser {
    navigateTo(router: Router, graph: RouteGraph, route: RouteInfo): boolean;
}
declare class Router {
    private hasHandleInitialURL;
    private uriPrefix?;
    constructor();
    clear(): void;
    addRouteConfig(moduleName: string, routeConfig: RouteConfig): void;
    registerInterceptor(func: RouteInterceptor): void;
    unregisterInterceptor(func: RouteInterceptor): void;
    registerParser(parser: RouteParser): void;
    pathToRoute(path: string): RouteInfo | null;
    navigateTo(graph: RouteGraph, route: RouteInfo): boolean;
    open(path: string): Promise<void>;
    activate(uriPrefix: string): void;
    inactivate(): void;
    private routeEventHandler;
}
declare const router: Router;
export { router };
