import { ReactRegistry, Garden, Navigator } from 'react-native-navigation-hybrid';
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

Garden.setStyle({
  topBarStyle: 'dark-content',
  titleTextSize: 17,
  // statusBarColor: '#0000FF',
  // topBarColor: '#F0FFFFFF',

  topBarTintColor: '#000000',
  // titleTextColor: '#00ff00',
  titleAlignment: 'center',
  // backIcon: Image.resolveAssetSource(require('./src/images/ic_settings.png')),
  shadowImage: {
    color: '#DDDDDD',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  // hideBackTitle: true,
  elevation: 1,

  bottomBarColor: '#FFFFFF',
  //bottomBarShadowImage: {
  //color: '#ff0000',
  // 	image: Image.resolveAssetSource(require('./src/images/divider.png'))
  //},
  // bottomBarButtonItemActiveColor: '#00FF00'
  bottomBarButtonItemInactiveColor: '#CCCCCC',
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

ReactRegistry.startRegisterComponent(screenWrapper);

ReactRegistry.registerComponent('Navigation', () => Navigation);
ReactRegistry.registerComponent('Result', () => Result, { path: 'result', mode: 'modal' });
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
ReactRegistry.registerComponent('TopBarStyle', () => TopBarStyle);

ReactRegistry.registerComponent('Transparent', () => Transparent);
ReactRegistry.registerComponent('HUDTest', () => HUDTest);
ReactRegistry.registerComponent('ReactModal', () => ReactModal);

ReactRegistry.endRegisterComponent();

Navigator.setRoot(
  {
    drawer: [
      {
        tabs: [
          {
            stack: {
              screen: { moduleName: 'Navigation' },
            },
          },
          {
            stack: {
              screen: { moduleName: 'Options' },
            },
          },
        ],
      },
      {
        screen: { moduleName: 'Menu' },
        options: {
          maxDrawerWidth: 280,
          minDrawerMargin: 64,
        },
      },
    ],
  },
  true
);

Navigator.setInterceptor((action, from, to, extras) => {
  console.info(`action:${action} from:${from} to:${to}`);
});
