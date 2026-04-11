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

export interface NavigationOption {
	screenBackgroundColor?: Color; // 页面背景，默认是白色
	statusBarHidden?: boolean; // 是否隐藏状态栏
	statusBarStyle?: BarStyle; // 状态栏样式，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
	navigationBarColorAndroid?: Color; // Android 底部虚拟按钮背景颜色
	navigationBarHiddenAndroid?: boolean; // 是否隐藏 Android 底部的虚拟导航栏
	fitsOpaqueNavigationBarAndroid?: boolean; // 适配不透明的导航栏边衬区，默认为 true
	displayCutoutWhenLandscapeAndroid?: boolean; // 横屏时，是否将界面延伸至刘海区域，默认 true
	homeIndicatorAutoHiddenIOS?: boolean; // 是否隐藏 Home 指示器，默认 false

	backInteractive?: boolean; // 是否允许侧滑返回或通过返回键返回
}

export interface NavigationItem extends NavigationOption {
	animatedTransition?: boolean;
	forceScreenLandscape?: boolean; // 是否强制横屏
	tabItem?: TabItem;
}

export interface BackItem {
	title: string;
	tintColor?: Color;
}

export interface TabItem {
	title: string;
	icon?: ImageSource;
	unselectedIcon?: ImageSource;
}

export interface ShadowImage {
	image?: ImageSource;
	color?: Color;
}

export interface DefaultOptions {
	screenBackgroundColor?: Color; // 页面背景，默认是白色
	statusBarStyle?: BarStyle; // 状态栏样式，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
	navigationBarColorAndroid?: Color; // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
	fitsOpaqueNavigationBarAndroid?: boolean; // 适配不透明的导航栏边衬区，默认为 true
	displayCutoutWhenLandscapeAndroid?: boolean; // 横屏时，是否将界面延伸至刘海区域，默认 true

	tabBarBackgroundColor?: Color; // 底部 TabBar 背景颜色，请勿使用带透明度的颜色。
	tabBarShadowImage?: ShadowImage; // 底部 TabBar 阴影图片。对于 iOS, 只有同时设置了 tabBarBackgroundColor 才会生效
	tabBarItemSelectedColor?: Color; // 底部 TabBarItem icon 选中颜色
	tabBarItemNormalColor?: Color; // 底部 TabBarItem icon 未选中颜色，默认为 #666666
	tabBarBadgeColor?: Color; //  Tab badge 颜色
}

export type TabBarStyle = Pick<
	DefaultOptions,
	| 'tabBarBackgroundColor'
	| 'tabBarShadowImage'
	| 'tabBarItemSelectedColor'
	| 'tabBarItemNormalColor'
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
