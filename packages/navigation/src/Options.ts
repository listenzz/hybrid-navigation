import type {Insets} from 'react-native';
import type {Navigator} from './Navigator';

export type Color = string;
export type ImageSource = {
	uri: string;
	scale?: number;
	height?: number;
	width?: number;
};
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

export const LayoutFittingExpanded = 'expanded';
export type LayoutFittingExpanded = typeof LayoutFittingExpanded;
export const LayoutFittingCompressed = 'compressed';
export type LayoutFittingCompressed = typeof LayoutFittingCompressed;
export type LayoutFitting = LayoutFittingExpanded | LayoutFittingCompressed;

export interface NavigationOption {
	screenBackgroundColor?: Color; // 页面背景，默认是白色
	statusBarHidden?: boolean; // 是否隐藏状态栏
	statusBarColorAndroid?: Color; // 状态栏背景颜色
	topBarStyle?: BarStyle; // TopBar 样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
	topBarColor?: Color; // TopBar 背景颜色
	topBarShadowHidden?: boolean; // 是否隐藏 TopBar 的阴影
	topBarAlpha?: number; // TopBar 背景透明度
	topBarTintColor?: Color; // TopBar 按钮颜色
	titleTextColor?: Color; // TopBar 标题题字体颜色
	titleTextSize?: number; // TopBar 标题字体大小
	navigationBarColorAndroid?: Color; // Android 底部虚拟按钮背景颜色
	navigationBarHiddenAndroid?: boolean; // 是否隐藏 Android 底部的虚拟导航栏
	fitsOpaqueNavigationBarAndroid?: boolean; // 适配不透明的导航栏边衬区，默认为 true
	displayCutoutWhenLandscapeAndroid?: boolean; // 横屏时，是否将界面延伸至刘海区域，默认 true
	homeIndicatorAutoHiddenIOS?: boolean; // 是否隐藏 Home 指示器，默认 false

	backButtonHidden?: boolean; // 是否显示返回按钮
	backInteractive?: boolean; // 是否允许侧滑返回或通过返回键返回
}

export interface NavigationItem extends NavigationOption {
	passThroughTouches?: boolean; // 触摸事件是否可以穿透到下一层页面，很少用。
	forceTransparentDialogWindow?: boolean; // 当页面是 Dialog 时，是否强制背景透明
	animatedTransition?: boolean;
	forceScreenLandscape?: boolean; // 是否强制横屏
	topBarHidden?: boolean; // 是否隐藏 TopBar
	extendedLayoutIncludesTopBar?: boolean; // 页面内容是否延伸到 TopBar 底下，通常用于需要动态改变 `topBarAlpha` 的场合
	swipeBackEnabled?: boolean; // 是否可以通过右滑返回。如果 `backInteractive` 设置为 false, 那么该值无效。Android 下，只有开启了侧滑返回功能，该值才会生效。
	titleItem?: TitleItem;
	leftBarButtonItem?: BarButtonItem;
	rightBarButtonItem?: BarButtonItem;
	leftBarButtonItems?: BarButtonItem[];
	rightBarButtonItems?: BarButtonItem[];
	backItemIOS?: BackItem;
	tabItem?: TabItem;
}

export interface BarButtonItem {
	title?: string;
	icon?: ImageSource;
	insetsIOS?: Insets;
	action?: (navigator: Navigator) => void;
	enabled?: boolean;
	tintColor?: Color;
	renderOriginal?: boolean;
}

export interface TitleItem {
	title?: string;
	moduleName?: string;
	layoutFitting?: LayoutFitting;
}

export interface BackItem {
	title: string;
	tintColor?: Color;
}

export interface TabItem {
	title: string;
	icon?: ImageSource;
	unselectedIcon?: ImageSource;
	hideTabBarWhenPush?: boolean;
}

export interface ShadowImage {
	image?: ImageSource;
	color?: Color;
}

export interface DefaultOptions {
	screenBackgroundColor?: Color; // 页面背景，默认是白色
	topBarStyle?: BarStyle; // TopBar 样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
	topBarColor?: Color; // TopBar 背景颜色，默认根据 topBarStyle 来计算
	topBarColorDarkContent?: Color; // TopBar 背景颜色，当 topBarStyle 的值为 BarStyleDarkContent 时生效，覆盖 topBarColor 的值
	topBarColorLightContent?: Color; // TopBar 背景颜色，当 topBarStyle 的值为 BarStyleLightContent 时生效，覆盖 topBarColor 的值
	statusBarColorAndroid?: Color; // 状态栏背景颜色，默认取 topBarColor 的值
	navigationBarColorAndroid?: Color; // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
	hideBackTitleIOS?: boolean; // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
	elevationAndroid?: number; // TopBar 阴影高度，默认值为 4 dp
	shadowImage?: ShadowImage; // TopBar 阴影图片，仅对 iOS 生效
	backIcon?: ImageSource; // 返回按钮图片
	topBarTintColor?: Color; // TopBar 按钮的颜色。默认根据 topBarStyle 来计算
	topBarTintColorDarkContent?: Color; // TopBar 按钮颜色，当 topBarStyle 的值为 BarStyleDarkContent 时生效，覆盖 topBarTintColor 的值
	topBarTintColorLightContent?: Color; // TopBar 按钮颜色，当 topBarStyle 的值为 BarStyleLightContent 时生效，覆盖 topBarTintColor 的值
	titleTextColor?: Color; // TopBar 标题颜色，默认根据 topBarStyle 来计算
	titleTextColorDarkContent?: Color; // TopBar 标题颜色，当 topBarStyle 的值为 BarStyleDarkContent 时生效，覆盖 titleTextColor 的值
	titleTextColorLightContent?: Color; // TopBar 标题颜色，当 topBarStyle 的值为 BarStyleLightContent 时生效，覆盖 titleTextColor 的值
	titleTextSize?: number; // TopBar 标题字体大小，默认是 17 dp(pt)
	titleAlignmentAndroid?: TitleAlignment; // TopBar 标题的位置，可选项有 `TitleAlignmentLeft` 和 `TitleAlignmentCenter` ，仅对 Android 生效
	barButtonItemTextSize?: number; // TopBar 按钮字体大小，默认是 15 dp(pt)
	swipeBackEnabledAndroid?: boolean; // Android 是否开启右滑返回，默认是 false
	splitTopBarTransitionIOS?: boolean; // iOS 侧滑返回时，是否总是割裂导航栏背景
	scrimAlphaAndroid?: number; // Android 侧滑返回遮罩效果 [0 - 255]
	fitsOpaqueNavigationBarAndroid?: boolean; // 适配不透明的导航栏边衬区，默认为 true
	displayCutoutWhenLandscapeAndroid?: boolean; // 横屏时，是否将界面延伸至刘海区域，默认 true

	tabBarColor?: Color; // 底部 TabBar 背景颜色，请勿使用带透明度的颜色。
	tabBarShadowImage?: ShadowImage; // 底部 TabBar 阴影图片。对于 iOS, 只有同时设置了 tabBarColor 才会生效
	tabBarItemColor?: Color; // 底部 TabBarItem icon 选中颜色
	tabBarUnselectedItemColor?: Color; // 底部 TabBarItem icon 未选中颜色，默认为 #BDBDBD
	tabBarBadgeColor?: Color; //  Tab badge 颜色
}

export type TabBarStyle = Pick<
	DefaultOptions,
	| 'tabBarColor'
	| 'tabBarShadowImage'
	| 'tabBarItemColor'
	| 'tabBarUnselectedItemColor'
>;

export interface TabItemInfo {
	index: number;
	title?: string;
	badge?: {
		text?: string;
		hidden: boolean;
		dot?: boolean;
	};
	icon?: {
		selected: ImageSource;
		unselected?: ImageSource;
	};
}
