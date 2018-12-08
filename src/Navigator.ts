import NavigationModule, { EventEmitter } from './NavigationModule';
import { bindBarButtonItemClickEvent } from './utils';
import store from './store';
import { EmitterSubscription } from 'react-native';
import { NavigationItem } from './Garden';
import { Route, RouteGraph } from './router';

let intercept: NavigationInterceptor;
let willSetRootCallback: () => void;
let didSetRootEventSubscription: EmitterSubscription;
let didSetRootCallback: () => void;
let shouldSwitchTabSubscription: EmitterSubscription;

interface NavigationProps {
  [propName: string]: any;
}

interface NavigationExtras {
  [propName: string]: any;
}

export type NavigationInterceptor = (
  action: string,
  from?: string,
  to?: string,
  extras?: NavigationExtras
) => boolean;

export interface Layout {}

export interface Screen extends Layout {
  screen: {
    moduleName: string;
    props?: {};
    options?: NavigationItem;
  };
}

export interface Stack extends Layout {
  stack: {
    children: Layout[];
    options?: {};
  };
}

export interface Tabs extends Layout {
  tabs: {
    children: Layout[];
    options?: { selectedIndex?: number };
  };
}

export interface Drawer extends Layout {
  drawer: {
    children: Layout[];
    options?: {
      maxDrawerWidth?: number;
      minDrawerMargin?: number;
      menuInteractive?: boolean;
    };
  };
}

export class Navigator {
  static RESULT_OK: -1 = NavigationModule.RESULT_OK;
  static RESULT_CANCEL: 0 = NavigationModule.RESULT_CANCEL;

  static get(sceneId: string): Navigator {
    return store.getNavigator(sceneId) || new Navigator(sceneId);
  }

  static async current() {
    const { sceneId } = await Navigator.currentRoute();
    return Navigator.get(sceneId);
  }

  static async currentRoute(): Promise<Route> {
    return await NavigationModule.currentRoute();
  }

  static async routeGraph(): Promise<RouteGraph[]> {
    return await NavigationModule.routeGraph();
  }

  static setRoot(layout: Layout, sticky = false) {
    if (willSetRootCallback) {
      willSetRootCallback();
    }

    if (didSetRootEventSubscription) {
      didSetRootEventSubscription.remove();
    }

    didSetRootEventSubscription = EventEmitter.addListener('ON_ROOT_SET', _ => {
      if (didSetRootCallback) {
        didSetRootCallback();
      }
    });

    if (shouldSwitchTabSubscription) {
      shouldSwitchTabSubscription.remove();
    }

    shouldSwitchTabSubscription = EventEmitter.addListener('SWITCH_TAB', event => {
      Navigator.dispatch(event.sceneId, 'switchTab', {
        index: event.index,
        from: event.from,
        moduleName: event.moduleName,
      });
    });

    const pureLayout = bindBarButtonItemClickEvent(layout, { inLayout: true });
    NavigationModule.setRoot(pureLayout, sticky);
  }

  static setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    willSetRootCallback = willSetRoot;
    didSetRootCallback = didSetRoot;
  }

  static dispatch(sceneId: string, action: string, extras: NavigationExtras = {}): void {
    extras.from = extras.from || Navigator.get(sceneId).moduleName;
    if (!intercept || !intercept(action, extras.from, extras.moduleName, extras)) {
      NavigationModule.dispatch(sceneId, action, extras);
    }
  }

  static setInterceptor(interceptor: NavigationInterceptor) {
    intercept = interceptor;
  }

  constructor(public sceneId: string, public moduleName?: string) {
    this.sceneId = sceneId;
    this.moduleName = moduleName;
    this.dispatch = this.dispatch.bind(this);
    this.setParams = this.setParams.bind(this);

    this.push = this.push.bind(this);
    this.pop = this.pop.bind(this);
    this.popTo = this.popTo.bind(this);
    this.popToRoot = this.popToRoot.bind(this);
    this.replace = this.replace.bind(this);
    this.replaceToRoot = this.replaceToRoot.bind(this);
    this.isRoot = this.isRoot.bind(this);

    this.present = this.present.bind(this);
    this.dismiss = this.dismiss.bind(this);
    this.showModal = this.showModal.bind(this);
    this.hideModal = this.hideModal.bind(this);
    this.setResult = this.setResult.bind(this);

    this.toggleMenu = this.toggleMenu.bind(this);
    this.openMenu = this.openMenu.bind(this);
    this.closeMenu = this.closeMenu.bind(this);
  }

  state: { params: { readonly [x: string]: any } } = { params: {} };

  setParams(params: { [x: string]: any }) {
    this.state.params = { ...this.state.params, ...params };
  }

  dispatch(action: string, extras: NavigationExtras = {}) {
    extras.from = this.moduleName;
    Navigator.dispatch(this.sceneId, action, extras);
  }

  push(
    moduleName: string,
    props: NavigationProps = {},
    options: NavigationItem = {},
    animated = true
  ) {
    this.dispatch('push', { moduleName, props, options, animated });
  }

  pushLayout(layout: Layout, animated = true) {
    this.dispatch('pushLayout', { layout, animated });
  }

  pop(animated = true) {
    this.dispatch('pop', { animated });
  }

  popTo(sceneId: string, animated = true) {
    this.dispatch('popTo', { animated, targetId: sceneId });
  }

  popToRoot(animated = true) {
    this.dispatch('popToRoot', { animated });
  }

  replace(moduleName: string, props: NavigationProps = {}, options: NavigationItem = {}) {
    this.dispatch('replace', { moduleName, props, options, animated: true });
  }

  replaceToRoot(moduleName: string, props: NavigationProps = {}, options: NavigationItem = {}) {
    this.dispatch('replaceToRoot', { moduleName, props, options, animated: true });
  }

  isRoot(): Promise<boolean> {
    return NavigationModule.isNavigationRoot(this.sceneId);
  }

  present(
    moduleName: string,
    requestCode = 0,
    props: NavigationProps = {},
    options: NavigationItem = {},
    animated = true
  ) {
    this.dispatch('present', {
      moduleName,
      props,
      options,
      requestCode,
      animated,
    });
  }

  presentLayout(layout: Layout, requestCode = 0, animated = true) {
    this.dispatch('presentLayout', { layout, requestCode, animated });
  }

  dismiss(animated = true) {
    this.dispatch('dismiss', { animated });
  }

  showModal(
    moduleName: string,
    requestCode = 0,
    props: NavigationProps = {},
    options: NavigationItem = {}
  ) {
    this.dispatch('showModal', {
      moduleName,
      props,
      options,
      requestCode,
    });
  }

  showModalLayout(layout: Layout, requestCode = 0) {
    this.dispatch('showModalLayout', { layout, requestCode });
  }

  hideModal() {
    this.dispatch('hideModal');
  }

  setResult(resultCode: number, data: { [x: string]: any } = {}): void {
    NavigationModule.setResult(this.sceneId, resultCode, data);
  }

  switchTab(index: number, popToRoot: boolean = false) {
    this.dispatch('switchTab', { index, popToRoot });
  }

  toggleMenu() {
    this.dispatch('toggleMenu');
  }

  openMenu() {
    this.dispatch('openMenu');
  }

  closeMenu() {
    this.dispatch('closeMenu');
  }

  signalFirstRenderComplete(): void {
    NavigationModule.signalFirstRenderComplete(this.sceneId);
  }
}
