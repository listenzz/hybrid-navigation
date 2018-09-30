import NavigationModule from './NavigationModule';
import { bindBarButtonItemClickEvent } from './utils';
import store from './store';
import router from './router';

let intercept;

export default class Navigator {
  static RESULT_OK = NavigationModule.RESULT_OK;
  static RESULT_CANCEL = NavigationModule.RESULT_CANCEL;

  static get(sceneId) {
    return store.getNavigator(sceneId) || new Navigator(sceneId);
  }

  static async current() {
    const { sceneId } = await router.currentRoute();
    return Navigator.get(sceneId);
  }

  static setRoot(layout, sticky = false) {
    const pureLayout = bindBarButtonItemClickEvent(layout, { inLayout: true });
    NavigationModule.setRoot(pureLayout, sticky);
  }

  static setInterceptor(interceptor) {
    intercept = interceptor;
  }

  static dispatch(sceneId, action, extras = {}) {
    if (!intercept || !intercept(action, this.moduleName, extras.moduleName, extras)) {
      NavigationModule.dispatch(sceneId, action, extras);
    }
  }

  constructor(sceneId, moduleName) {
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

  state = { params: {} };

  setParams(params = {}) {
    this.state.params = { ...this.state.params, ...params };
  }

  dispatch(action, extras = {}) {
    Navigator.dispatch(this.sceneId, action, extras);
  }

  push(moduleName, props = {}, options = {}, animated = true) {
    this.dispatch('push', { moduleName, props, options, animated });
  }

  pushLayout(layout = {}, animated = true) {
    this.dispatch('pushLayout', { layout, animated });
  }

  pop(animated = true) {
    this.dispatch('pop', { animated });
  }

  popTo(sceneId, animated = true) {
    this.dispatch('popTo', { animated, targetId: sceneId });
  }

  popToRoot(animated = true) {
    this.dispatch('popToRoot', { animated });
  }

  replace(moduleName, props = {}, options = {}) {
    this.dispatch('replace', { moduleName, props, options, animated: true });
  }

  replaceToRoot(moduleName, props = {}, options = {}) {
    this.dispatch('replaceToRoot', { moduleName, props, options, animated: true });
  }

  isRoot() {
    return NavigationModule.isNavigationRoot(this.sceneId);
  }

  present(moduleName, requestCode = 0, props = {}, options = {}, animated = true) {
    this.dispatch('present', {
      moduleName,
      props,
      options,
      requestCode,
      animated,
    });
  }

  presentLayout(layout = {}, requestCode = 0, animated = true) {
    this.dispatch('presentLayout', { layout, requestCode, animated });
  }

  dismiss(animated = true) {
    this.dispatch('dismiss', { animated });
  }

  showModal(moduleName, requestCode = 0, props = {}, options = {}) {
    this.dispatch('showModal', {
      moduleName,
      props,
      options,
      requestCode,
    });
  }

  showModalLayout(layout = {}, requestCode = 0) {
    this.dispatch('showModalLayout', { layout, requestCode });
  }

  hideModal() {
    this.dispatch('hideModal');
  }

  setResult(resultCode, data = {}) {
    NavigationModule.setResult(this.sceneId, resultCode, data);
  }

  switchTab(index) {
    this.dispatch('switchTab', { index });
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

  signalFirstRenderComplete() {
    NavigationModule.signalFirstRenderComplete(this.sceneId);
  }
}
