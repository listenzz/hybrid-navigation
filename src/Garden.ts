import { NativeModules, Insets } from 'react-native'
import { bindBarButtonItemClickEvent } from './utils'
import { Navigator } from './Navigator'

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

export type Color = string
export type Image = { uri: string; scale?: number; height?: number; width?: number }

export interface ShadowImage {
  image?: Image
  color?: Color
}

export interface Style {
  screenBackgroundColor?: Color // 页面背景，默认是白色
  topBarStyle?: BarStyle // 顶部导航栏样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor?: Color // 顶部导航栏背景颜色，默认根据 topBarStyle 来计算
  statusBarColorAndroid?: Color // 状态栏背景颜色，默认取 topBarColor 的值， 仅对 Android 5.0 以上版本生效
  navigationBarColorAndroid?: Color // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
  hideBackTitleIOS?: boolean // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
  elevationAndroid?: number // 顶部导航栏阴影高度，默认值为 4 dp， 仅对 Android 5.0 以上版本生效
  shadowImage?: ShadowImage // 顶部导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效
  backIcon?: Image // 返回按钮图片
  topBarTintColor?: Color // 顶部导航栏按钮的颜色。默认根据 topBarStyle 来计算
  titleTextColor?: Color // 顶部导航栏标题颜色，默认根据 topBarStyle 来计算
  titleTextSize?: number // 顶部导航栏标题字体大小，默认是 17 dp(pt)
  titleAlignmentAndroid?: TitleAlignment // 顶部导航栏标题的位置，可选项有 `TitleAlignmentLeft` 和 `TitleAlignmentCenter` ，仅对 Android 生效
  barButtonItemTextSize?: number // 顶部导航栏按钮字体大小，默认是 15 dp(pt)
  swipeBackEnabledAndroid?: boolean // Android 是否开启右滑返回，默认是 false

  tabBarColor?: Color // 底部 TabBar 背景颜色，请勿使用带透明度的颜色。
  tabBarShadowImage?: ShadowImage // 底部 TabBar 阴影图片。对于 iOS, 只有同时设置了 tabBarColor 才会生效
  tabBarItemColor?: Color // 底部 TabBarItem icon 选中颜色
  tabBarUnselectedItemColor?: Color // 底部 TabBarItem icon 未选中颜色，默认为 #BDBDBD
  tabBarBadgeColor?: Color //  Tab badge 颜色
}

export interface NavigationOption {
  passThroughTouches?: boolean // 触摸事件是否可以穿透到下一层页面，很少用。
  statusBarHidden?: boolean // 是否隐藏状态栏
  statusBarColorAndroid?: Color // 状态栏背景颜色
  topBarStyle?: BarStyle // 顶部导航栏样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor?: Color // 当前页面顶部导航栏背景颜色
  topBarShadowHidden?: boolean // 是否隐藏当前页面导航栏的阴影
  topBarAlpha?: number // 当前页面顶部导航栏背景透明度
  topBarTintColor?: Color // 当前页面按钮颜色
  titleTextColor?: Color // 当前页面顶部导航栏标题字体颜色
  titleTextSize?: number // 当前页面顶部导航栏标题字体大小
  navigationBarColorAndroid?: Color // Android 底部虚拟按钮背景颜色
  backButtonHidden?: boolean // 是否显示返回按钮
  backInteractive?: boolean // 是否允许侧滑返回或通过返回键返回
}

export interface NavigationItem extends NavigationOption {
  screenBackgroundColor?: Color // 当前页面背景
  topBarHidden?: boolean // 是否隐藏当前页面的顶部导航栏
  extendedLayoutIncludesTopBar?: boolean // 当前页面的内容是否延伸到 topBar 底下，通常用于需要动态改变 `topBarAlpha` 的场合
  swipeBackEnabled?: boolean // 当前页面是否可以通过右滑返回。如果 `backInteractive` 设置为 false, 那么该值无效。Android 下，只有开启了侧滑返回功能，该值才会生效。
  titleItem?: TitleItem
  leftBarButtonItem?: BarButtonItem
  rightBarButtonItem?: BarButtonItem
  leftBarButtonItems?: BarButtonItem[]
  rightBarButtonItems?: BarButtonItem[]
  backItemIOS?: BackItem
  tabItem?: TabItem
}

export const LayoutFittingExpanded = 'expanded'
export type LayoutFittingExpanded = typeof LayoutFittingExpanded
export const LayoutFittingCompressed = 'compressed'
export type LayoutFittingCompressed = typeof LayoutFittingCompressed
export type LayoutFitting = LayoutFittingExpanded | LayoutFittingCompressed

export interface TitleItem {
  title?: string
  moduleName?: string
  layoutFitting?: LayoutFitting
}

export interface BarButtonItem {
  title?: string
  icon?: Image
  insetsIOS?: Insets
  action?: (navigator: Navigator) => void
  enabled?: boolean
  tintColor?: Color
  renderOriginal?: boolean
}

export interface BackItem {
  title: string
  tintColor?: Color
}

export interface TabItem {
  title: string
  icon?: Image
  unselectedIcon?: Image
  hideTabBarWhenPush?: boolean
}

export interface TabBadge {
  index: number
  text?: string
  hidden: boolean
  dot?: boolean
}

export interface TabIcon {
  index: number
  icon: Image
  unselectedIcon?: Image
}

const GardenModule = NativeModules.GardenHybrid
export class Garden {
  static setStyle(style: Style = {}) {
    GardenModule.setStyle(style)
  }

  constructor(public sceneId: string) {
    this.sceneId = sceneId
  }

  // --------------- instance method --------------

  setLeftBarButtonItem(buttonItem: BarButtonItem | null) {
    const options = bindBarButtonItemClickEvent(buttonItem, { sceneId: this.sceneId })
    GardenModule.setLeftBarButtonItem(this.sceneId, options)
  }

  setRightBarButtonItem(buttonItem: BarButtonItem | null) {
    const options = bindBarButtonItemClickEvent(buttonItem, { sceneId: this.sceneId })
    GardenModule.setRightBarButtonItem(this.sceneId, options)
  }

  setTitleItem(titleItem: TitleItem) {
    GardenModule.setTitleItem(this.sceneId, titleItem)
  }

  updateOptions(options: NavigationOption) {
    GardenModule.updateOptions(this.sceneId, options)
  }

  updateTabBar(
    options: Pick<
      Style,
      'tabBarColor' | 'tabBarShadowImage' | 'tabBarItemColor' | 'tabBarUnselectedItemColor'
    >,
  ) {
    GardenModule.updateTabBar(this.sceneId, options)
  }

  setTabIcon(icon: TabIcon | TabIcon[]) {
    if (!Array.isArray(icon)) {
      icon = [icon]
    }
    GardenModule.setTabIcon(this.sceneId, icon)
  }

  setTabBadge(badge: TabBadge | TabBadge[]) {
    if (!Array.isArray(badge)) {
      badge = [badge]
    }
    GardenModule.setTabBadge(this.sceneId, badge)
  }

  setMenuInteractive(enabled: boolean) {
    GardenModule.setMenuInteractive(this.sceneId, enabled)
  }
}
