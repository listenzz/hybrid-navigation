import Navigation, {
	DeepLink,
	BarStyleDarkContent,
	Drawer,
	Screen,
	Tabs,
	Stack,
} from 'hybrid-navigation';
import NavigationScreen from './Navigation';
import Result from './Result';
import Options from './Options';
import Menu from './Menu';
import PassOptions from './PassOptions';

import Noninteractive from './Noninteractive';
import TopBarStyle from './TopBarStyle';
import ReactModal from './ReactModal';
import StatusBarHidden from './StatusBarHidden';
import Landscape from './Landscape';
import SafeAreaContextHOC from './SafeAreaContextHOC';
import demoTheme from './Theme';

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
	screenBackgroundColor: demoTheme.colors.background,
	statusBarStyle: BarStyleDarkContent,
	navigationBarColorAndroid: demoTheme.colors.surface,

	tabBarBackgroundColor: demoTheme.colors.background,

	tabBarShadowImage: {
		color: demoTheme.colors.border,
	},
	tabBarItemNormalColor: demoTheme.colors.tabUnselected,
	tabBarItemSelectedColor: demoTheme.colors.tabSelected,
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

Navigation.registerComponent('Noninteractive', () => Noninteractive);
Navigation.registerComponent('StatusBarHidden', () => StatusBarHidden);
Navigation.registerComponent('TopBarStyle', () => TopBarStyle, {
	path: '/topBarStyle/:who',
	dependency: 'Options',
});

Navigation.registerComponent('ReactModal', () => ReactModal, {
	path: '/modal',
	mode: 'modal',
});

Navigation.registerComponent('Landscape', () => Landscape);

// 完成注册组件
Navigation.endRegisterComponent();

const tabs: Tabs = {
	tabs: {
		children: [{ screen: { moduleName: 'Navigation' } }, { screen: { moduleName: 'Options' } }],
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

const rootStack: Stack = {
	stack: {
		children: [drawer],
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
Navigation.setRoot(rootStack);

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
