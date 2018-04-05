/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import { AppRegistry, DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';
import React, { Component } from 'react';
import Navigation from './Navigation';
import NavigationModule from './NavigationModule';
import Garden from './Garden';

const EventEmitter = Platform.select({
  ios: new NativeEventEmitter(NavigationModule),
  android: DeviceEventEmitter,
});

let componentWrapperFunc;

let navigations = new Map();

function copy(obj = {}) {
  let target = {};
  for (const key of Object.keys(obj)) {
    const value = obj[key];
    if (value && typeof value === 'object') {
      if (value.constructor === Array) {
        let array = [];
        target[key] = array;
        for (let i = 0; i < value.length; i++) {
          array.push(copy(value[i]));
        }
      } else {
        target[key] = copy(value);
      }
    } else {
      target[key] = value;
    }
  }
  return target;
}

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
        if (navigations.has(props.sceneId)) {
          this.navigation = navigations.get(props.sceneId);
        } else {
          this.navigation = new Navigation(props.sceneId);
          navigations.set(props.sceneId, this.navigation);
        }
        this.options = copy(RealComponent.navigationItem);
        this.garden = new Garden(props.sceneId, this.options);
        this.events = [];
      }

      listenBarButtonItemClickEvent() {
        let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', event => {
          if (this.props.sceneId === event.sceneId && RealComponent.navigationItem) {
            // console.info(JSON.stringify(event));
            if (event.action === 'right_bar_button_item_click') {
              this.options.rightBarButtonItem.action(this.navigation);
            } else if (event.action === 'left_bar_button_item_click') {
              this.options.leftBarButtonItem.action(this.navigation);
            } else if (event.action.startsWith('right_bar_button_item_click_')) {
              let index = event.action.replace('right_bar_button_item_click_', '');
              this.options.rightBarButtonItems[index].action(this.navigation);
            } else if (event.action.startsWith('left_bar_button_item_click_')) {
              let index = event.action.replace('left_bar_button_item_click_', '');
              this.options.leftBarButtonItems[index].action(this.navigation);
            } else if (this.refs.real.onBarButtonItemClick) {
              this.refs.real.onBarButtonItemClick(event.action); // 向后兼容
            }
          }
        });
        this.events.push(event);
      }

      listenComponentResultEvent() {
        let event = EventEmitter.addListener('ON_COMPONENT_RESULT', event => {
          if (this.props.sceneId === event.sceneId && this.refs.real.onComponentResult) {
            this.refs.real.onComponentResult(event.requestCode, event.resultCode, event.data);
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
        this.navigation.signalFirstRenderComplete();
      }

      componentWillUnmount() {
        // console.debug('componentWillUnmount = ' + this.props.sceneId);
        navigations.delete(this.props.sceneId);
        this.events.forEach(event => {
          event.remove();
        });
      }

      render() {
        return (
          <RealComponent
            ref="real"
            {...this.props}
            navigation={this.navigation}
            navigator={this.navigation} // 向后兼容
            garden={this.garden}
          />
        );
      }
    }

    let RootComponent;
    if (componentWrapperFunc) {
      RootComponent = componentWrapperFunc(() => Screen);
    } else {
      RootComponent = Screen;
    }

    // build static options
    let options = copy(RealComponent.navigationItem);
    if (options.leftBarButtonItem && typeof options.leftBarButtonItem.action === 'function') {
      options.leftBarButtonItem.action = 'left_bar_button_item_click';
    }

    if (options.rightBarButtonItem && typeof options.rightBarButtonItem.action === 'function') {
      options.rightBarButtonItem.action = 'right_bar_button_item_click';
    }

    if (options.leftBarButtonItems) {
      let items = options.leftBarButtonItems;
      for (let i = 0; i < items.length; i++) {
        let item = items[i];
        if (typeof item.action === 'function') {
          item.action = 'left_bar_button_item_click_' + i;
        }
      }
    }

    if (options.rightBarButtonItems) {
      let items = options.rightBarButtonItems;
      for (let i = 0; i < items.length; i++) {
        let item = items[i];
        if (typeof item.action === 'function') {
          item.action = 'right_bar_button_item_click_' + i;
        }
      }
    }

    // console.info('register component:' + appKey + ' options:' + JSON.stringify(options));

    AppRegistry.registerComponent(appKey, () => RootComponent);
    NavigationModule.registerReactComponent(appKey, options);
  },
};
