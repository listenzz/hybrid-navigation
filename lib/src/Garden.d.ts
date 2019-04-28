import { Insets } from 'react-native';
import { Navigator } from './Navigator';
export declare const BarStyleLightContent = "light-content";
export declare type BarStyleLightContent = typeof BarStyleLightContent;
export declare const BarStyleDarkContent = "dark-content";
export declare type BarStyleDarkContent = typeof BarStyleDarkContent;
export declare type BarStyle = BarStyleLightContent | BarStyleDarkContent;
export declare const TitleAlignmentLeft = "left";
export declare type TitleAlignmentLeft = typeof TitleAlignmentLeft;
export declare const TitleAlignmentCenter = "center";
export declare type TitleAlignmentCenter = typeof TitleAlignmentCenter;
export declare type TitleAlignment = TitleAlignmentCenter | TitleAlignmentLeft;
export declare type Color = string;
export declare type Image = {
    uri: string;
    scale?: number;
    height?: number;
    width?: number;
};
export interface ShadowImage {
    image?: Image;
    color?: Color;
}
export interface Style {
    screenBackgroundColor?: Color;
    topBarStyle?: BarStyle;
    topBarColor?: Color;
    statusBarColorAndroid?: Color;
    navigationBarColorAndroid?: Color;
    hideBackTitleIOS?: boolean;
    elevationAndroid?: number;
    shadowImage?: ShadowImage;
    backIcon?: Image;
    topBarTintColor?: Color;
    titleTextColor?: Color;
    titleTextSize?: number;
    titleAlignmentAndroid?: TitleAlignment;
    barButtonItemTextSize?: number;
    swipeBackEnabledAndroid?: boolean;
    tabBarColor?: Color;
    tabBarShadowImage?: ShadowImage;
    tabBarItemColor?: Color;
    tabBarSelectedItemColor?: Color;
    badgeColor?: Color;
}
export interface NavigationItem {
    passThroughTouches?: boolean;
    screenBackgroundColor?: Color;
    topBarStyle?: BarStyle;
    topBarColor?: Color;
    topBarAlpha?: number;
    extendedLayoutIncludesTopBar?: boolean;
    topBarTintColor?: Color;
    titleTextColor?: Color;
    titleTextSize?: number;
    topBarShadowHidden?: boolean;
    topBarHidden?: boolean;
    statusBarHidden?: boolean;
    statusBarColorAndroid?: Color;
    navigationBarColorAndroid?: Color;
    backButtonHidden?: boolean;
    backInteractive?: boolean;
    swipeBackEnabled?: boolean;
    titleItem?: TitleItem;
    leftBarButtonItem?: BarButtonItem;
    rightBarButtonItem?: BarButtonItem;
    leftBarButtonItems?: BarButtonItem[];
    rightBarButtonItems?: BarButtonItem[];
    backItemIOS?: BackItem;
    tabItem?: TabItem;
}
export declare const LayoutFittingExpanded = "expanded";
export declare type LayoutFittingExpanded = typeof LayoutFittingExpanded;
export declare const LayoutFittingCompressed = "compressed";
export declare type LayoutFittingCompressed = typeof LayoutFittingCompressed;
export declare type LayoutFitting = LayoutFittingExpanded | LayoutFittingCompressed;
export interface TitleItem {
    title?: string;
    moduleName?: string;
    layoutFitting?: LayoutFitting;
}
export declare type Action = (navigator: Navigator) => void;
export interface BarButtonItem {
    title?: string;
    icon?: Image;
    insetsIOS?: Insets;
    action?: string | Action;
    enabled?: boolean;
    tintColor?: Color;
    renderOriginal?: boolean;
}
export interface BackItem {
    title: string;
    tintColor?: Color;
}
export interface TabItem {
    title: string;
    icon: Image;
    selectedIcon?: Image;
    hideTabBarWhenPush?: boolean;
}
export interface TabBarOptions {
    tabBarColor?: Color;
    tabBarShadowImage?: Image;
    tabBarItemColor?: Color;
    tabBarUnselectedItemColor?: Color;
}
export interface StatusBarOptions {
    statusBarColor: Color;
}
export declare class Garden {
    sceneId: string;
    static toolbarHeight: number;
    static DARK_CONTENT: BarStyleDarkContent;
    static LIGHT_CONTENT: BarStyleLightContent;
    static setStyle(style?: Style): void;
    constructor(sceneId: string);
    setStatusBarColorAndroid(options: StatusBarOptions): void;
    setStatusBarHidden(hidden?: boolean): void;
    setPassThroughTouches(item: NavigationItem): void;
    setLeftBarButtonItem(buttonItem?: BarButtonItem): void;
    setRightBarButtonItem(buttonItem: BarButtonItem): void;
    setTitleItem(item: TitleItem): void;
    updateTopBar(item?: NavigationItem): void;
    updateTabBar(options?: TabBarOptions): void;
    replaceTabIcon(index: number, icon: Image, inactiveIcon: Image): void;
    setTabBadgeText(index: number, text: string): void;
    setTabBadge(index: number, text: string): void;
    showRedPointAtIndex(index: number): void;
    hideRedPointAtIndex(index: number): void;
    setMenuInteractive(enabled: boolean): void;
}
