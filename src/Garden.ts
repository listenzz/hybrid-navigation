import { NativeModules, Platform, Insets } from 'react-native';
const GardenModule = NativeModules.GardenHybrid;
import { bindBarButtonItemClickEvent } from './utils';
import { Navigator } from './Navigator';

export const BarStyleLightContent = 'light-content';
export type BarStyleLightContent = typeof BarStyleLightContent;
export const BarStyleDarkContent = 'dark-content';
export type BarStyleDarkContent = typeof BarStyleDarkContent;
export type BarStyle = BarStyleLightContent | BarStyleDarkContent;

export const TitleAlignmentLeft = 'left';
export type TitleAlignmentLeft = typeof TitleAlignmentLeft;
export const TitleAlignmentCenter = 'center';
export type TitleAlignmentCenter = typeof TitleAlignmentCenter;
export type TitleAlignment = TitleAlignmentCenter | TitleAlignmentLeft;

export type Color = string;
export type Image = { uri: string; scale?: number; height?: number; width?: number };

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

export const LayoutFittingExpanded = 'expanded';
export type LayoutFittingExpanded = typeof LayoutFittingExpanded;
export const LayoutFittingCompressed = 'compressed';
export type LayoutFittingCompressed = typeof LayoutFittingCompressed;
export type LayoutFitting = LayoutFittingExpanded | LayoutFittingCompressed;

export interface TitleItem {
  title?: string;
  moduleName?: string;
  layoutFitting?: LayoutFitting;
}

export type Action = (navigator: Navigator) => void;

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

export class Garden {
  static toolbarHeight: number = GardenModule.TOOLBAR_HEIGHT;
  static DARK_CONTENT: BarStyleDarkContent = GardenModule.DARK_CONTENT;
  static LIGHT_CONTENT: BarStyleLightContent = GardenModule.LIGHT_CONTENT;

  static setStyle(style: Style = {}) {
    GardenModule.setStyle(style);
  }

  constructor(public sceneId: string) {
    this.sceneId = sceneId;
  }

  // --------------- instance method --------------

  setStatusBarColorAndroid(options: StatusBarOptions) {
    if (Platform.OS === 'android') {
      GardenModule.setStatusBarColor(this.sceneId, options);
    }
  }

  setStatusBarHidden(hidden = true) {
    GardenModule.setStatusBarHidden(this.sceneId, { statusBarHidden: hidden });
  }

  setPassThroughTouches(item: NavigationItem) {
    GardenModule.setPassThroughtouches(item);
  }

  setLeftBarButtonItem(buttonItem: BarButtonItem = {}) {
    const options = bindBarButtonItemClickEvent(buttonItem, { sceneId: this.sceneId });
    GardenModule.setLeftBarButtonItem(this.sceneId, options);
  }

  setRightBarButtonItem(buttonItem: BarButtonItem) {
    const options = bindBarButtonItemClickEvent(buttonItem, { sceneId: this.sceneId });
    GardenModule.setRightBarButtonItem(this.sceneId, options);
  }

  setTitleItem(item: TitleItem) {
    GardenModule.setTitleItem(this.sceneId, item);
  }

  updateTopBar(item: NavigationItem = {}) {
    GardenModule.updateTopBar(this.sceneId, item);
  }

  updateTabBar(options: TabBarOptions = {}) {
    GardenModule.updateTabBar(this.sceneId, options);
  }

  replaceTabIcon(index: number, icon: Image, inactiveIcon: Image) {
    GardenModule.replaceTabIcon(this.sceneId, index, icon, inactiveIcon);
  }

  setTabBadgeText(index: number, text: string) {
    GardenModule.setTabBadgeText(this.sceneId, index, text);
  }

  setTabBadge(index: number, text: string) {
    console.warn(
      '`setTabBadge` has been deprecated and will be removed in the next release, please use `setTabBadgeText`'
    );
    GardenModule.setTabBadgeText(this.sceneId, index, text);
  }

  showRedPointAtIndex(index: number) {
    GardenModule.showRedPointAtIndex(index, this.sceneId);
  }

  hideRedPointAtIndex(index: number) {
    GardenModule.hideRedPointAtIndex(index, this.sceneId);
  }

  setMenuInteractive(enabled: boolean) {
    GardenModule.setMenuInteractive(this.sceneId, enabled);
  }
}
