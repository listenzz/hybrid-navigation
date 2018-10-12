import { ReactRegistry, Garden, Navigator, router } from 'react-native-navigation-hybrid';
import { Image, Platform } from 'react-native';
import React, { Component } from 'react';

import { Provider } from 'react-redux';

import Navigation from './src/Navigation';
import Result from './src/Result';
import Options from './src/Options';
import Menu from './src/Menu';
import PassOptions from './src/PassOptions';
import ReduxCounter, { store } from './src/ReduxCounter';
import Lifecycle from './src/Lifecycle';

import TopBarMisc from './src/TopBarMisc';
import Noninteractive from './src/Noninteractive';
import TopBarShadowHidden from './src/TopBarShadowHidden';
import TopBarHidden from './src/TopBarHidden';
import TopBarColor from './src/TopBarColor';
import TopBarAlpha from './src/TopBarAlpha';
import TopBarTitleView, { CustomTitleView } from './src/TopBarTitleView';
import TopBarStyle from './src/TopBarStyle';
import StatusBarColor from './src/StatusBarColor';
import Transparent from './src/Transparent';
import HUDTest from './src/HUDText';
import ReactModal from './src/ReactModal';
import StatusBarHidden from './src/StatusBarHidden';

// 设置全局样式
Garden.setStyle({
  topBarStyle: 'dark-content',
  titleTextSize: 17,
  // statusBarColor: '#0000FF',
  topBarColor: '#FFFFFF',

  swipeBackEnabledAndroid: true,
  topBarTintColor: '#000000',
  // badgeColor: '#00FFFF',
  // titleTextColor: '#00ff00',
  titleAlignment: 'center',
  // backIcon: Image.resolveAssetSource(require('./src/images/ic_settings.png')),
  shadowImage: {
    color: '#DDDDDD',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  // hideBackTitle: true,
  elevation: 1,

  tabBarColor: '#FFFFFF',
  tabBarShadowImage: {
    color: '#F0F0F0',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  //tabBarItemColor: '#CCCCCC',
  //tabBarSelectedItemColor: '#00ff00',
});

function screenWrapper(screenProvider) {
  const Screen = screenProvider();
  class ScreenWrapper extends Component {
    componentDidMount() {
      // 获取屏幕名称
      const screenName = Screen.componentName;
      console.info(`screenName:${screenName}`);
    }

    render() {
      return (
        <Provider store={store}>
          <Screen {...this.props} />
        </Provider>
      );
    }
  }
  return ScreenWrapper;
}

// 开始注册组件，即基本页面单元
ReactRegistry.startRegisterComponent(screenWrapper);

ReactRegistry.registerComponent('Navigation', () => Navigation);
ReactRegistry.registerComponent('Result', () => Result, { path: 'result', mode: 'present' });
ReactRegistry.registerComponent('Options', () => Options, { path: 'options' });
ReactRegistry.registerComponent('Menu', () => Menu, { path: 'menu' });
ReactRegistry.registerComponent('ReduxCounter', () => ReduxCounter, { path: 'redux' });
ReactRegistry.registerComponent('PassOptions', () => PassOptions);
ReactRegistry.registerComponent('Lifecycle', () => Lifecycle);

ReactRegistry.registerComponent('TopBarMisc', () => TopBarMisc, { dependency: 'Options' });
ReactRegistry.registerComponent('Noninteractive', () => Noninteractive);
ReactRegistry.registerComponent('TopBarShadowHidden', () => TopBarShadowHidden);
ReactRegistry.registerComponent('TopBarHidden', () => TopBarHidden);
ReactRegistry.registerComponent('TopBarAlpha', () => TopBarAlpha, {
  path: 'topBarAlpha/:alpha/:color',
  dependency: 'TopBarMisc',
});
ReactRegistry.registerComponent('TopBarColor', () => TopBarColor, {
  path: 'topBarColor/:color',
  dependency: 'TopBarMisc',
});
ReactRegistry.registerComponent('TopBarTitleView', () => TopBarTitleView);
ReactRegistry.registerComponent('CustomTitleView', () => CustomTitleView);
ReactRegistry.registerComponent('StatusBarColor', () => StatusBarColor);
ReactRegistry.registerComponent('StatusBarHidden', () => StatusBarHidden);
ReactRegistry.registerComponent('TopBarStyle', () => TopBarStyle);

ReactRegistry.registerComponent('Transparent', () => Transparent);
ReactRegistry.registerComponent('HUDTest', () => HUDTest);
ReactRegistry.registerComponent('ReactModal', () => ReactModal, { path: 'modal', mode: 'modal' });

// 完成注册组件
ReactRegistry.endRegisterComponent();

const navigationStack = {
  stack: {
    children: [{ screen: { moduleName: 'Navigation' } }],
  },
};

const optionsStack = {
  stack: {
    children: [{ screen: { moduleName: 'Options' } }],
  },
};

const tabs = { tabs: { children: [navigationStack, optionsStack] } };

const menu = { screen: { moduleName: 'Menu' } };

const drawer = {
  drawer: {
    children: [tabs, menu],
    options: {
      maxDrawerWidth: 280,
      minDrawerMargin: 64,
    },
  },
};

// 激活 DeepLink，在 Navigator.setRoot 之前
Navigator.setRootLayoutUpdateListener(
  () => {
    router.inactivate();
  },
  () => {
    const prefix = Platform.OS == 'android' ? 'hbd://hbd/' : 'hbd://';
    router.activate(prefix);
  }
);

// 设置 UI 层级
Navigator.setRoot(drawer);

// 设置导航拦截器
Navigator.setInterceptor((action, from, to, extras) => {
  console.info(`action:${action} from:${from} to:${to}`);
});
