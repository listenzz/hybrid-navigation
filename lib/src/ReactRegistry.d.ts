import { ComponentProvider } from 'react-native';
import React from 'react';
import { Navigator } from './Navigator';
import { Garden, NavigationItem } from './Garden';
import { RouteConfig } from './router';
export interface NavigationType {
    navigationItem?: NavigationItem;
}
export interface Navigation {
    onBarButtonItemClick?(action: string): void;
    onComponentResult?(requestCode: number, resultCode: number, data: {
        [x: string]: any;
    }): void;
    componentDidAppear?(): void;
    componentDidDisappear?(): void;
    onBackPressed?(): void;
}
export interface Props {
    navigator: Navigator;
    garden: Garden;
}
export declare type HigherOrderComponent = (WrappedComponent: React.ComponentType) => React.ComponentType;
export declare class ReactRegistry {
    static registerEnded: boolean;
    static startRegisterComponent(hoc?: HigherOrderComponent): void;
    static endRegisterComponent(): void;
    static registerComponent(appKey: string, getComponentFunc: ComponentProvider, routeConfig?: RouteConfig): void;
}
