import {
  ReactRegistry,
  Garden,
  Navigator,
  DeepLink,
  BarStyleDarkContent,
  TitleAlignmentCenter,
  Drawer,
  Screen,
  Tabs,
  Stack,
} from 'hybrid-navigation'
import { Platform } from 'react-native'
import Navigation from './Navigation'
import Result from './Result'
import Options from './Options'
import Menu from './Menu'
import PassOptions from './PassOptions'
import ReduxCounter, { withRedux } from './ReduxCounter'
import Lifecycle from './Lifecycle'

import TopBarMisc from './TopBarMisc'
import Noninteractive from './Noninteractive'
import TopBarShadowHidden from './TopBarShadowHidden'
import TopBarHidden from './TopBarHidden'
import TopBarColor from './TopBarColor'
import TopBarAlpha from './TopBarAlpha'
import TopBarTitleView, { CustomTitleView } from './TopBarTitleView'
import TopBarStyle from './TopBarStyle'
import StatusBarColor from './StatusBarColor'
import ReactModal from './ReactModal'
import StatusBarHidden from './StatusBarHidden'
import CustomTabBar from './CustomTabBar'
import BulgeTabBar from './BulgeTabBar'
import Toast from './Toast'

// import MessageQueue from 'react-native/Libraries/BatchedBridge/MessageQueue.js';
// const spyFunction = msg => {
//   console.debug(msg);
// };
// MessageQueue.spy(spyFunction);

async function graph() {
  const graph = await Navigator.routeGraph()
  console.log(graph)
}

graph()

// 设置全局样式
Garden.setStyle({
  screenBackgroundColor: '#F8F8F8',
  topBarStyle: BarStyleDarkContent,

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

  statusBarColorAndroid: Platform.OS === 'android' && Platform.Version < 23 ? '#4A4A4A' : undefined,
  titleAlignmentAndroid: TitleAlignmentCenter,
  navigationBarColorAndroid: '#FFFFFF',
  // scrimAlphaAndroid: 50,

  // backIcon: Image.resolveAssetSource(require('./src/images/ic_settings.png')),
  shadowImage: {
    color: '#DDDDDD',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  // hideBackTitleIOS: true,
  elevationAndroid: 1,

  tabBarColor: '#FFFFFF',

  tabBarShadowImage: {
    color: '#F0F0F0',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  //tabBarItemColor: '#CCCCCC',
  //tabBarSelectedItemColor: '#00ff00',
})

// 开始注册组件，即基本页面单元
ReactRegistry.startRegisterComponent(withRedux)

ReactRegistry.registerComponent('Navigation', () => Navigation)
ReactRegistry.registerComponent('Result', () => Result, { path: '/result', mode: 'present' })
ReactRegistry.registerComponent('Options', () => Options, { path: '/options' })
ReactRegistry.registerComponent('Menu', () => Menu, { path: '/menu' })
ReactRegistry.registerComponent('ReduxCounter', () => ReduxCounter, { path: '/redux' })
ReactRegistry.registerComponent('PassOptions', () => PassOptions)
ReactRegistry.registerComponent('Lifecycle', () => Lifecycle)

ReactRegistry.registerComponent('TopBarMisc', () => TopBarMisc, { dependency: 'Options' })
ReactRegistry.registerComponent('Noninteractive', () => Noninteractive)
ReactRegistry.registerComponent('TopBarShadowHidden', () => TopBarShadowHidden)
ReactRegistry.registerComponent('TopBarHidden', () => TopBarHidden)
ReactRegistry.registerComponent('TopBarAlpha', () => TopBarAlpha, {
  path: '/topBarAlpha/:alpha',
  dependency: 'TopBarMisc',
})
ReactRegistry.registerComponent('TopBarColor', () => TopBarColor, {
  path: '/topBarColor/:color',
  dependency: 'TopBarMisc',
})
ReactRegistry.registerComponent('TopBarTitleView', () => TopBarTitleView)
ReactRegistry.registerComponent('CustomTitleView', () => CustomTitleView)
ReactRegistry.registerComponent('StatusBarColor', () => StatusBarColor)
ReactRegistry.registerComponent('StatusBarHidden', () => StatusBarHidden)
ReactRegistry.registerComponent('TopBarStyle', () => TopBarStyle)

ReactRegistry.registerComponent('ReactModal', () => ReactModal, { path: '/modal', mode: 'modal' })

ReactRegistry.registerComponent('CustomTabBar', () => CustomTabBar)
ReactRegistry.registerComponent('BulgeTabBar', () => BulgeTabBar)
ReactRegistry.registerComponent('Toast', () => Toast)

// 完成注册组件
ReactRegistry.endRegisterComponent()

const navigationStack: Stack = {
  stack: {
    children: [{ screen: { moduleName: 'Navigation' } }],
  },
}

const optionsStack: Stack = {
  stack: {
    children: [{ screen: { moduleName: 'Options' } }],
  },
}

const tabs: Tabs = {
  tabs: {
    children: [navigationStack, optionsStack],
    options: {
      //tabBarModuleName: 'BulgeTabBar',
      //sizeIndeterminate: true,
      //tabBarModuleName: 'CustomTabBar',
      //sizeIndeterminate: false,
      //selectedIndex: 1,
    },
  },
}

const menu: Screen = { screen: { moduleName: 'Menu' } }

const drawer: Drawer = {
  drawer: {
    children: [tabs, menu],
    options: {
      maxDrawerWidth: 280,
      minDrawerMargin: 64,
    },
  },
}

// 激活 DeepLink，在 Navigator.setRoot 之前
Navigator.setRootLayoutUpdateListener(
  () => {
    DeepLink.deactivate()
    console.log('------------------------deactivate router')
  },
  () => {
    const prefix = 'hbd://'
    DeepLink.activate(prefix)
    console.log('------------------------activate router')
  },
)

// 设置 UI 层级
Navigator.setRoot(drawer)

// 设置导航拦截器
Navigator.setInterceptor(async (action, extras) => {
  console.info(`action:${action}`, extras)

  // const current = await Navigator.current()
  // if (current.moduleName === to) {
  //   // 拦截跳转
  //   return true
  // }
  // 不拦截任何操作
  return false
})
