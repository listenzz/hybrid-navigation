/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import { AppRegistry, DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';
import React, { Component } from 'react';
import Navigator from './Navigator';
import NavigationModule from './NavigationModule';
import Garden from './Garden';

const EventEmitter = Platform.select({
  ios: new NativeEventEmitter(NavigationModule),
  android: DeviceEventEmitter,
});

let componentWrapperFunc;

export default {
  startRegisterComponent(componentWrapper) {
    console.info('begin register react component');
    componentWrapperFunc = componentWrapper;
    NavigationModule.startRegisterReactComponent();
  },

  endRegisterComponent() {
    NavigationModule.endRegisterReactComponent();
    console.info('end register react component');
  },

  registerComponent(appKey, componentProvider) {
    const RealComponent = componentProvider();

    class Screen extends Component {
      constructor(props) {
        super(props);
        this.navigator = new Navigator(props.sceneId);
        this.garden = new Garden(props.sceneId);
        this.events = [];
      }

      handleBarButtonItemClick() {
        let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', event => {
          if (this.props.sceneId === event.sceneId && this.navigator.onBarButtonItemClick) {
            this.navigator.onBarButtonItemClick(event.action);
          }
        });
        this.events.push(event);
      }

      handleComponentResultEvent() {
        let event = EventEmitter.addListener('ON_COMPONENT_RESULT', event => {
          if (this.props.sceneId === event.sceneId && this.navigator.onComponentResult) {
            this.navigator.onComponentResult(event.requestCode, event.resultCode, event.data);
          }
        });
        this.events.push(event);
      }

      componentWillMount() {
        console.debug('componentWillMount   = ' + this.props.sceneId);
        this.handleComponentResultEvent();
        this.handleBarButtonItemClick();
      }

      componentDidMount() {
        console.debug('componentDidMount    = ' + this.props.sceneId);
        this.navigator.signalFirstRenderComplete();
      }

      componentWillUnmount() {
        console.debug('componentWillUnmount = ' + this.props.sceneId);
        this.events.forEach(event => {
          event.remove();
        });
      }

      render() {
        let RootComponent;
        if (componentWrapperFunc) {
          RootComponent = componentWrapperFunc(() => RealComponent);
        } else {
          RootComponent = RealComponent;
        }
        return <RootComponent {...this.props} navigator={this.navigator} garden={this.garden} />;
      }
    }

    // build static options
    let options = {};
    if (RealComponent.navigationItem) {
      options = RealComponent.navigationItem;
    }

    console.debug('register component:' + appKey + ' options:' + JSON.stringify(options));

    AppRegistry.registerComponent(appKey, () => Screen);
    NavigationModule.registerReactComponent(appKey, options);
  },
};
