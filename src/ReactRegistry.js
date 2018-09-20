import { AppRegistry } from 'react-native';
import React, { Component } from 'react';
import Navigator from './Navigator';
import NavigationModule, { EventEmitter } from './NavigationModule';
import Garden from './Garden';
import router from './Router';
import store from './Store';
import { bindBarButtonItemClickEvent, removeBarButtonItemClickEvent } from './utils';

let componentWrapperFunc;

export default {
  startRegisterComponent(componentWrapper) {
    console.info('begin register react component');
    router.clear();
    store.clear();
    componentWrapperFunc = componentWrapper;
    NavigationModule.startRegisterReactComponent();
  },

  endRegisterComponent() {
    NavigationModule.endRegisterReactComponent();
    console.info('end register react component');
  },

  registerComponent(appKey, componentProvider, routeConfig) {
    const RealComponent = componentProvider();
    if (RealComponent.routeConfig) {
      RealComponent.routeConfig.moduleName = appKey;
      router.addRoute(appKey, RealComponent.routeConfig);
    }
    if (routeConfig) {
      router.addRoute(appKey, routeConfig);
    }

    class Screen extends Component {
      static InternalComponent = RealComponent;

      events;

      constructor(props) {
        super(props);
        this.navigator = store.getNavigator(props.sceneId) || new Navigator(props.sceneId, appKey);
        store.addNavigator(props.sceneId, this.navigator);
        this.garden = new Garden(props.sceneId);
        this.events = [];
      }

      listenBarButtonItemClickEvent() {
        let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', event => {
          if (
            this.props.sceneId === event.sceneId &&
            RealComponent.navigationItem &&
            this.refs.real.onBarButtonItemClick
          ) {
            this.refs.real.onBarButtonItemClick(event.action); // 向后兼容
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

      listenDialogBackPressedEvent() {
        let event = EventEmitter.addListener('ON_DIALOG_BACK_PRESSED', event => {
          if (this.props.sceneId === event.sceneId && this.refs.real.onBackPressed) {
            this.refs.real.onBackPressed();
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
        this.listenDialogBackPressedEvent();
        this.navigator.signalFirstRenderComplete();
      }

      componentWillUnmount() {
        // console.debug('componentWillUnmount = ' + this.props.sceneId);
        store.removeNavigator(this.props.sceneId);
        removeBarButtonItemClickEvent(this.props.sceneId);
        this.events.forEach(event => {
          event.remove();
        });
      }

      render() {
        return (
          <RealComponent
            ref="real"
            {...this.props}
            navigation={this.navigator} // 向后兼容
            navigator={this.navigator}
            garden={this.garden}
          />
        );
      }
    }

    let RootComponent;
    Screen.componentName = appKey;
    if (componentWrapperFunc) {
      RootComponent = componentWrapperFunc(() => Screen);
    } else {
      RootComponent = Screen;
    }

    // build static options
    let options = bindBarButtonItemClickEvent(RealComponent.navigationItem);

    // console.info('register component:' + appKey + ' options:' + JSON.stringify(options));

    AppRegistry.registerComponent(appKey, () => RootComponent);
    NavigationModule.registerReactComponent(appKey, options);
  },
};
