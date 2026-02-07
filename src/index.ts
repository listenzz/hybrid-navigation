import Navigation, {
	DeepLink,
	BarStyleDarkContent,
	TitleAlignmentCenter,
	Drawer,
	Screen,
	Tabs,
	Stack,
} from 'hybrid-navigation';
import { Image, Platform } from 'react-native';
import NavigationScreen from './Navigation';
import Result from './Result';
import Options from './Options';
import Menu from './Menu';
import PassOptions from './PassOptions';

import TopBarMisc from './TopBarMisc';
import Noninteractive from './Noninteractive';
import TopBarShadowHidden from './TopBarShadowHidden';
import TopBarHidden from './TopBarHidden';
import TopBarColor from './TopBarColor';
import TopBarAlpha from './TopBarAlpha';
import TopBarTitleView, { CustomTitleView } from './TopBarTitleView';
import TopBarStyle from './TopBarStyle';
import ReactModal from './ReactModal';
import StatusBarHidden from './StatusBarHidden';
import Landscape from './Landscape';
import SafeAreaContextHOC from './SafeAreaContextHOC';

// LogBox.ignoreAllLogs();

// import MessageQueue from 'react-native/Libraries/BatchedBridge/MessageQueue.js';
// const spyFunction = msg => {
//   console.debug(msg);
// };
// MessageQueue.spy(spyFunction);

async function graph() {
	console.log(JSON.stringify(await Navigation.routeGraph(), null, 2));
}

graph();

// 设置全局样式
Navigation.setDefaultOptions({
	screenBackgroundColor: '#F8F8F8',
	topBarStyle: BarStyleDarkContent,
	//topBarHidden: true,

	topBarColor: '#FFFFFF',
	...Platform.select({
		ios: {
			topBarColorLightContent: '#FF344C',
		},
		android: {
			topBarColorLightContent: '#F94D53',
		},
	}),
	topBarTintColor: '#000000',
	topBarTintColorLightContent: '#FFFFFF',
	titleTextColor: '#000000',
	titleTextColorLightContent: '#FFFFFF',
	titleTextSize: 17,
	swipeBackEnabledAndroid: true,
	// splitTopBarTransitionIOS: true,
	// badgeColor: '#00FFFF',
	titleAlignmentAndroid: TitleAlignmentCenter,
	navigationBarColorAndroid: '#FFFFFF',
	// scrimAlphaAndroid: 50,

	backIcon:
		Platform.OS === 'ios'
			? Image.resolveAssetSource(require('./images/icon_back.png'))
			: undefined,
	shadowImage: {
		color: '#DDDDDD',
		image: Image.resolveAssetSource(require('./images/divider.png')),
	},
	// hideBackTitleIOS: true,
	elevationAndroid: 1,

	tabBarBackgroundColor: '#FFFFFF',

	tabBarShadowImage: {
		// color: '#F0F0F0',
		// image: Image.resolveAssetSource(require('./images/divider.png')),
	},
	tabBarItemNormalColor: '#666666',
	tabBarItemSelectedColor: '#FF5722',
});

// 开始注册组件，即基本页面单元

Navigation.startRegisterComponent(SafeAreaContextHOC);

Navigation.registerComponent('Navigation', () => NavigationScreen);
Navigation.registerComponent('Result', () => Result, {
	path: '/result',
	mode: 'present',
});
Navigation.registerComponent('Options', () => Options, { path: '/options' });
Navigation.registerComponent('Menu', () => Menu, { path: '/menu' });
Navigation.registerComponent('PassOptions', () => PassOptions);

Navigation.registerComponent('TopBarMisc', () => TopBarMisc, {
	dependency: 'Options',
});
Navigation.registerComponent('Noninteractive', () => Noninteractive);
Navigation.registerComponent('TopBarShadowHidden', () => TopBarShadowHidden);
Navigation.registerComponent('TopBarHidden', () => TopBarHidden);
Navigation.registerComponent('TopBarAlpha', () => TopBarAlpha);
Navigation.registerComponent('TopBarColor', () => TopBarColor);
Navigation.registerComponent('TopBarTitleView', () => TopBarTitleView);
Navigation.registerComponent('CustomTitleView', () => CustomTitleView);
Navigation.registerComponent('StatusBarHidden', () => StatusBarHidden);
Navigation.registerComponent('TopBarStyle', () => TopBarStyle, {
	path: '/topBarStyle/:who',
	dependency: 'TopBarMisc',
});

Navigation.registerComponent('ReactModal', () => ReactModal, {
	path: '/modal',
	mode: 'modal',
});

Navigation.registerComponent('Landscape', () => Landscape);

// 完成注册组件
Navigation.endRegisterComponent();

const navigationStack: Stack = {
	stack: {
		children: [{ screen: { moduleName: 'Navigation' } }],
	},
};

const optionsStack: Stack = {
	stack: {
		children: [{ screen: { moduleName: 'Options' } }],
	},
};

const tabs: Tabs = {
	tabs: {
		children: [navigationStack, optionsStack],
		options: {
			// selectedIndex: 1,
		},
	},
};

const menu: Screen = { screen: { moduleName: 'Menu' } };

const drawer: Drawer = {
	drawer: {
		children: [tabs, menu],
		options: {
			maxDrawerWidth: 280,
			minDrawerMargin: 64,
		},
	},
};

// 激活 DeepLink，在 Navigation.setRoot 之前
Navigation.setRootLayoutUpdateListener(
	() => {
		DeepLink.deactivate();
		console.log('------------------------deactivate router');
	},
	() => {
		const prefix = 'hbd://';
		DeepLink.activate(prefix);
		console.log('------------------------activate router');
	},
);

// 设置 UI 层级
Navigation.setRoot(drawer);

// 设置导航拦截器
Navigation.setInterceptor(async (action, extras) => {
	console.info(`action:${action}`, extras);

	// const current = await Navigation.currentRoute()
	// if (current.moduleName === extras.to) {
	//   // 拦截跳转
	//   return true
	// }
	// // 不拦截任何操作
	return false;
});
