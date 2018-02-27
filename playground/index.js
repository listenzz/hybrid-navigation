/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import { ReactRegistry, Garden, Navigator } from 'react-native-navigation-hybrid';
import { Image } from 'react-native';
import React, { Component } from 'react';

import { Provider } from 'react-redux';
import Counter, { store } from './src/Counter';

import App from './App';
import ReactNavigation from './src/ReactNavigation';
import ReactResult from './src/ReactResult';
import CustomStyle from './src/CustomStyle';
import HideBackButton from './src/HideBackButton';
import HideTopBarShadow from './src/HideTopBarShadow';
import PassOptions from './src/PassOptions';
import Menu from './src/Menu';

Garden.setStyle({
  topBarStyle: 'dark-content',
  titleTextSize: 17,
  // statusBarColor: '#FFFFFF',
  // topBarBackgroundColor: '#FFFFFF',

  // topBarTintColor: '#0000ff',
  // backIcon: Image.resolveAssetSource(require('./src/ic_settings.png')),
  shadowImage: {
    color: '#dddddd',
    //image: Image.resolveAssetSource(require('./src/divider.png'))
  },
  // hideBackTitle: true,
  elevation: 1,

  bottomBarBackgroundColor: '#ffffff',
  //bottomBarShadowImage: {
  //color: '#ff0000',
  // 	image: Image.resolveAssetSource(require('./src/divider.png'))
  //},
  // bottomBarButtonItemActiveColor: '#00FF00'
  bottomBarButtonItemInActiveColor: '#CCCCCC',
});

function componentWrapper(componentProvider) {
  const InnerComponent = componentProvider();
  class Wrapper extends Component {
    render() {
      return (
        <Provider store={store}>
          <InnerComponent {...this.props} />
        </Provider>
      );
    }
  }
  return Wrapper;
}

ReactRegistry.startRegisterComponent(componentWrapper);

ReactRegistry.registerComponent('Navigator', () => App);
ReactRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
ReactRegistry.registerComponent('Navigation', () => ReactNavigation);
ReactRegistry.registerComponent('ReactResult', () => ReactResult);
ReactRegistry.registerComponent('CustomStyle', () => CustomStyle);
ReactRegistry.registerComponent('HideBackButton', () => HideBackButton);
ReactRegistry.registerComponent('HideTopBarShadow', () => HideTopBarShadow);
ReactRegistry.registerComponent('PassOptions', () => PassOptions);
ReactRegistry.registerComponent('Menu', () => Menu);
ReactRegistry.registerComponent('Counter', () => Counter);

ReactRegistry.endRegisterComponent();

// Navigator.setRoot({
//   drawer: [
//     {
//       tabs: [
//         {
//           stack: {
//             screen: { moduleName: 'ReactNavigation' },
//           },
//         },
//         {
//           stack: {
//             screen: { moduleName: 'CustomStyle' },
//           },
//         },
//       ],
//     },
//     { screen: { moduleName: 'Menu' } },
//   ],
// });
