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

let navigators = new Map();

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
        if (navigators.has(props.sceneId)) {
          this.navigator = navigators.get(props.sceneId);
        } else {
          this.navigator = new Navigator(props.sceneId);
          navigators.set(props.sceneId, this.navigator);
        }
        this.garden = new Garden(props.sceneId);
        this.events = [];
      }

      listenBarButtonItemClickEvent() {
        let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', event => {
          if (this.props.sceneId === event.sceneId && this.navigator.onBarButtonItemClick) {
            this.navigator.onBarButtonItemClick(event.action);
          }
        });
        this.events.push(event);
      }

      listenComponentResultEvent() {
        let event = EventEmitter.addListener('ON_COMPONENT_RESULT', event => {
          if (this.props.sceneId === event.sceneId && this.navigator.onComponentResult) {
            this.navigator.onComponentResult(event.requestCode, event.resultCode, event.data);
          }
        });
        this.events.push(event);
      }

      listenComponentResumeEvent() {
        // console.info('listenComponentResumeEvent');
        let event = EventEmitter.addListener('ON_COMPONENT_APPEAR', event => {
          if (this.props.sceneId === event.sceneId && this.refs.real.componentDidAppear) {
            this.refs.real.componentDidAppear();
          }
        });
        this.events.push(event);
      }

      listenComponentPauseEvent() {
        let event = EventEmitter.addListener('ON_COMPONENT_DISAPPEAR', event => {
          if (this.props.sceneId === event.sceneId && this.refs.real.componentDidDisappear) {
            this.refs.real.componentDidDisappear();
          }
        });
        this.events.push(event);
      }

      componentDidMount() {
        // console.debug('componentDidMount    = ' + this.props.sceneId);
        this.listenComponentResultEvent();
        this.listenBarButtonItemClickEvent();
        this.listenComponentResumeEvent();
        this.listenComponentPauseEvent();
        this.navigator.signalFirstRenderComplete();
      }

      componentWillUnmount() {
        // console.debug('componentWillUnmount = ' + this.props.sceneId);
        navigators.delete(this.props.sceneId);
        this.events.forEach(event => {
          event.remove();
        });
      }

      render() {
        return (
          <RealComponent
            ref="real"
            {...this.props}
            navigator={this.navigator}
            garden={this.garden}
          />
        );
      }
    }

    // build static options
    let options = {};
    if (RealComponent.navigationItem) {
      options = RealComponent.navigationItem;
    }

    console.debug('register component:' + appKey + ' options:' + JSON.stringify(options));
    let RootComponent;
    if (componentWrapperFunc) {
      RootComponent = componentWrapperFunc(() => Screen);
    } else {
      RootComponent = Screen;
    }

    AppRegistry.registerComponent(appKey, () => RootComponent);
    NavigationModule.registerReactComponent(appKey, options);
  },
};
