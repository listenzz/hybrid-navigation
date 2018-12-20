import { AppRegistry, EmitterSubscription, ComponentProvider, Platform } from 'react-native';
import React, { Component, ComponentType } from 'react';
import { Navigator } from './Navigator';
import NavigationModule, { EventEmitter } from './NavigationModule';
import { Garden, NavigationItem } from './Garden';
import { router, RouteConfig } from './router';
import store from './store';
import { bindBarButtonItemClickEvent, removeBarButtonItemClickEvent } from './utils';

export type ScreenProvider = () => ScreenType;

export type ScreenWrapper = (screenProvider: ScreenProvider) => React.ComponentType;

export interface ScreenType extends React.ComponentClass {
  componentName: string;
}

interface ScreenProps {
  sceneId?: string;
}

export interface NavigationType<P = Props, S = {}> extends React.ComponentClass<P, S>, Navigation {
  new (props: P, context?: any): Navigation;
  navigationItem?: NavigationItem;
}

export interface Navigation extends Component {
  onBarButtonItemClick?(action: string): void;
  onComponentResult?(requestCode: number, resultCode: number, data: { [x: string]: any }): void;
  componentDidAppear?(): void;
  componentDidDisappear?(): void;
  onBackPressed?(): void;
}

export interface Props {
  navigator: Navigator;
  garden: Garden;
}

class NavigationDriver extends React.Component<{
  sceneId: string;
  moduleName: string;
  NavigationComponent: NavigationType;
}> {
  navigator: Navigator;
  garden: Garden;
  private events: EmitterSubscription[] = [];
  constructor(props: any) {
    super(props);

    this.navigator =
      store.getNavigator(props.sceneId) || new Navigator(props.sceneId, props.moduleName);
    store.addNavigator(props.sceneId, this.navigator);
    this.garden = new Garden(props.sceneId);
    this.events = [];
  }

  componentDidMount() {
    // console.debug('componentDidMount    = ' + this.props.sceneId);
    this.listenComponentResultEvent();
    this.listenBarButtonItemClickEvent();
    this.listenComponentResumeEvent();
    this.listenComponentPauseEvent();
    this.listenDialogBackPressedEvent();
    this.navigator.signalFirstRenderComplete();
    this.listenMakeSureComponentDidMountEvent();
  }

  componentWillUnmount() {
    // console.debug('componentWillUnmount = ' + this.props.sceneId);
    store.removeNavigator(this.props.sceneId);
    removeBarButtonItemClickEvent(this.props.sceneId);
    this.events.forEach(event => {
      event.remove();
    });
  }

  listenBarButtonItemClickEvent() {
    let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', event => {
      const navigation = this.asNavigationType();
      if (this.props.sceneId === event.sceneId && navigation.onBarButtonItemClick) {
        navigation.onBarButtonItemClick(event.action); // 向后兼容
      }
    });
    this.events.push(event);
  }

  listenComponentResultEvent() {
    let event = EventEmitter.addListener('ON_COMPONENT_RESULT', event => {
      const navigation = this.asNavigationType();
      if (this.props.sceneId === event.sceneId && navigation.onComponentResult) {
        navigation.onComponentResult(event.requestCode, event.resultCode, event.data);
      }
    });
    this.events.push(event);
  }

  listenComponentResumeEvent() {
    // console.info('listenComponentResumeEvent');
    let event = EventEmitter.addListener('ON_COMPONENT_APPEAR', event => {
      const navigation = this.asNavigationType();
      if (this.props.sceneId === event.sceneId && navigation.componentDidAppear) {
        navigation.componentDidAppear();
      }
    });
    this.events.push(event);
  }

  listenComponentPauseEvent() {
    let event = EventEmitter.addListener('ON_COMPONENT_DISAPPEAR', event => {
      const navigation = this.asNavigationType();
      if (this.props.sceneId === event.sceneId && navigation.componentDidDisappear) {
        navigation.componentDidDisappear();
      }
    });
    this.events.push(event);
  }

  listenMakeSureComponentDidMountEvent() {
    if (Platform.OS === 'ios') {
      let event = EventEmitter.addListener('MAKE_SURE_COMPONENT_DID_MOUNT', event => {
        if (this.props.sceneId === event.sceneId) {
          this.navigator.signalFirstRenderComplete();
        }
      });
      this.events.push(event);
    }
  }

  listenDialogBackPressedEvent() {
    let event = EventEmitter.addListener('ON_DIALOG_BACK_PRESSED', event => {
      const navigation = this.asNavigationType();
      if (this.props.sceneId === event.sceneId && navigation.onBackPressed) {
        navigation.onBackPressed();
      }
    });
    this.events.push(event);
  }

  asNavigationType() {
    return this.refs.navigation as Navigation;
  }

  render() {
    const { NavigationComponent, ...props } = this.props;
    return (
      <NavigationComponent
        ref="navigation"
        {...props}
        navigator={this.navigator}
        garden={this.garden}
      />
    );
  }
}

let screenWrapperFunc: ScreenWrapper | undefined;

export class ReactRegistry {
  static registerEnded: boolean;
  static startRegisterComponent(screenWrapper?: ScreenWrapper) {
    console.info('begin register react component');
    router.clear();
    store.clear();
    screenWrapperFunc = screenWrapper;
    ReactRegistry.registerEnded = false;
    NavigationModule.startRegisterReactComponent();
  }

  static endRegisterComponent() {
    if (ReactRegistry.registerEnded) {
      console.warn('Please do not clall ReactRegistry#endRegisterComponent multiple times.');
      return;
    }
    ReactRegistry.registerEnded = true;
    NavigationModule.endRegisterReactComponent();
    console.info('end register react component');
  }

  static registerComponent(
    appKey: string,
    getComponentFunc: ComponentProvider,
    routeConfig?: RouteConfig
  ) {
    const NavigationComponent = getComponentFunc() as NavigationType;

    if (routeConfig) {
      router.addRouteConfig(appKey, routeConfig);
    }

    class Screen extends React.Component<ScreenProps> {
      static componentName: string = appKey;
      render() {
        if (this.props.sceneId) {
          return (
            <NavigationDriver
              {...this.props}
              sceneId={this.props.sceneId}
              moduleName={appKey}
              NavigationComponent={NavigationComponent}
            />
          );
        } else {
          return <NavigationComponent {...this.props} />;
        }
      }
    }

    let RootComponent: ComponentType;
    if (screenWrapperFunc) {
      RootComponent = screenWrapperFunc(() => Screen);
    } else {
      RootComponent = Screen;
    }

    // build static options
    let options = NavigationComponent.navigationItem
      ? bindBarButtonItemClickEvent(NavigationComponent.navigationItem)
      : {};

    // console.info('register component:' + appKey + ' options:' + JSON.stringify(options));

    AppRegistry.registerComponent(appKey, () => RootComponent);
    NavigationModule.registerReactComponent(appKey, options);
  }
}
