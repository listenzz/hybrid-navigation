import { Insets } from 'react-native'
import { Navigator } from './Navigator'

export interface IndexType {
  [index: string]: any
}

export interface PropsType {
  [index: string]: any
}

export type ResultType = IndexType | null

interface Extras {
  sceneId: string
  from?: number | string
  to?: number | string
}

export interface NavigationInterceptor {
  (action: string, extras: Extras): boolean | Promise<boolean>
}

export type Color = string
export type ImageSource = { uri: string; scale?: number; height?: number; width?: number }
export const BarStyleLightContent = 'light-content'
export type BarStyleLightContent = typeof BarStyleLightContent
export const BarStyleDarkContent = 'dark-content'
export type BarStyleDarkContent = typeof BarStyleDarkContent
export type BarStyle = BarStyleLightContent | BarStyleDarkContent

export const TitleAlignmentLeft = 'left'
export type TitleAlignmentLeft = typeof TitleAlignmentLeft
export const TitleAlignmentCenter = 'center'
export type TitleAlignmentCenter = typeof TitleAlignmentCenter
export type TitleAlignment = TitleAlignmentCenter | TitleAlignmentLeft

export const LayoutFittingExpanded = 'expanded'
export type LayoutFittingExpanded = typeof LayoutFittingExpanded
export const LayoutFittingCompressed = 'compressed'
export type LayoutFittingCompressed = typeof LayoutFittingCompressed
export type LayoutFitting = LayoutFittingExpanded | LayoutFittingCompressed

export interface NavigationOption {
  screenBackgroundColor?: Color // 页面背景，默认是白色
  passThroughTouches?: boolean // 触摸事件是否可以穿透到下一层页面，很少用。
  statusBarHidden?: boolean // 是否隐藏状态栏
  statusBarColorAndroid?: Color // 状态栏背景颜色
  topBarStyle?: BarStyle // TopBar 样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor?: Color // TopBar 背景颜色
  topBarShadowHidden?: boolean // 是否隐藏 TopBar 的阴影
  topBarAlpha?: number // TopBar 背景透明度
  topBarTintColor?: Color // TopBar 按钮颜色
  titleTextColor?: Color // TopBar 标题题字体颜色
  titleTextSize?: number // TopBar 标题字体大小
  navigationBarColorAndroid?: Color // Android 底部虚拟按钮背景颜色
  navigationBarHiddenAndroid?: boolean // 是否隐藏 Android 底部的虚拟导航栏
  displayCutoutWhenLandscapeAndroid?: boolean // 横屏时，是否将界面延伸至刘海区域，默认 true
  homeIndicatorAutoHiddenIOS?: boolean // 是否隐藏 Home 指示器，默认 false

  backButtonHidden?: boolean // 是否显示返回按钮
  backInteractive?: boolean // 是否允许侧滑返回或通过返回键返回
}

export interface NavigationItem extends NavigationOption {
  screenBackgroundColor?: Color // 当前页面背景
  forceTransparentDialogWindow?: boolean // 当页面是 Dialog 时，是否强制背景透明
  topBarHidden?: boolean // 是否隐藏 TopBar
  extendedLayoutIncludesTopBar?: boolean // 页面内容是否延伸到 TopBar 底下，通常用于需要动态改变 `topBarAlpha` 的场合
  swipeBackEnabled?: boolean // 是否可以通过右滑返回。如果 `backInteractive` 设置为 false, 那么该值无效。Android 下，只有开启了侧滑返回功能，该值才会生效。
  titleItem?: TitleItem
  leftBarButtonItem?: BarButtonItem
  rightBarButtonItem?: BarButtonItem
  leftBarButtonItems?: BarButtonItem[]
  rightBarButtonItems?: BarButtonItem[]
  backItemIOS?: BackItem
  tabItem?: TabItem
}

export interface BarButtonItem {
  title?: string
  icon?: ImageSource
  insetsIOS?: Insets
  action?: (navigator: Navigator) => void
  enabled?: boolean
  tintColor?: Color
  renderOriginal?: boolean
}

export interface TitleItem {
  title?: string
  moduleName?: string
  layoutFitting?: LayoutFitting
}

export interface BackItem {
  title: string
  tintColor?: Color
}

export interface TabItem {
  title: string
  icon?: ImageSource
  unselectedIcon?: ImageSource
  hideTabBarWhenPush?: boolean
}

export interface Layout {
  [index: string]: {}
}

export interface Screen extends Layout {
  screen: {
    moduleName: string
    props?: IndexType
    options?: NavigationItem
  }
}

export interface Stack extends Layout {
  stack: {
    children: (Screen | Tabs | Drawer)[]
    options?: {}
  }
}

export interface Tabs extends Layout {
  tabs: {
    children: (Screen | Stack | Drawer)[]
    options?: {
      selectedIndex?: number
      tabBarModuleName?: string
      sizeIndeterminate?: boolean
    }
  }
}

export interface Drawer extends Layout {
  drawer: {
    children: [Screen | Stack | Tabs, Screen | Stack | Tabs]
    options?: {
      maxDrawerWidth?: number
      minDrawerMargin?: number
      menuInteractive?: boolean
    }
  }
}
