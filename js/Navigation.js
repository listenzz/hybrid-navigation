/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import NavigationModule from './NavigationModule';

export default class Navigattion {
  /**
   * ```
   * {
   *  drawer: [
   *    { tabs: [
   *        { stack:
   *          { screen: "Home" }
   *        },
   *        { stack:
   *          { screen: "Profile" }
   *        },
   *      ]
   *    },
   *    { screen: "Setting" }
   *  ]
   * }
   * ```
   */
  static setRoot(layout) {
    // console.info('root:' + JSON.stringify(layout));
    NavigationModule.setRoot(layout);
  }

  constructor(sceneId) {
    this.sceneId = sceneId;
    this.push = this.push.bind(this);
    this.pop = this.pop.bind(this);
    this.popTo = this.popTo.bind(this);
    this.popToRoot = this.popToRoot.bind(this);
    this.isRoot = this.isRoot.bind(this);
    this.present = this.present.bind(this);
    this.setResult = this.setResult.bind(this);
    this.dismiss = this.dismiss.bind(this);
    this.replace = this.replace.bind(this);
    this.replaceToRoot = this.replaceToRoot.bind(this);
    this.onBarButtonItemClick = undefined;
    this.onComponentResult = undefined;
    this.state = { params: {} };
  }

  setParams(params = {}) {
    this.state.params = { ...this.state.params, ...params };
  }

  push(moduleName, props = {}, options = {}, animated = true) {
    NavigationModule.push(this.sceneId, moduleName, props, options, animated);
  }

  pop(animated = true) {
    NavigationModule.pop(this.sceneId, animated);
  }

  popTo(sceneId, animated = true) {
    NavigationModule.popTo(this.sceneId, sceneId, animated);
  }

  popToRoot(animated = true) {
    NavigationModule.popToRoot(this.sceneId, animated);
  }

  isRoot() {
    return NavigationModule.isRoot(this.sceneId);
  }

  replace(moduleName, props = {}, options = {}) {
    NavigationModule.replace(this.sceneId, moduleName, props, options);
  }

  replaceToRoot(moduleName, props = {}, options = {}) {
    NavigationModule.replaceToRoot(this.sceneId, moduleName, props, options);
  }

  present(moduleName, requestCode, props = {}, options = {}, animated = true) {
    NavigationModule.present(this.sceneId, moduleName, requestCode, props, options, animated);
  }

  setResult(resultCode, data = {}) {
    NavigationModule.setResult(this.sceneId, resultCode, data);
  }

  dismiss(animated = true) {
    NavigationModule.dismiss(this.sceneId, animated);
  }

  switchToTab(index) {
    NavigationModule.switchToTab(this.sceneId, index);
  }

  setTabBadge(index, text) {
    NavigationModule.setTabBadge(this.sceneId, index, text);
  }

  toggleMenu() {
    NavigationModule.toggleMenu(this.sceneId);
  }

  openMenu() {
    NavigationModule.openMenu(this.sceneId);
  }

  closeMenu() {
    NavigationModule.closeMenu(this.sceneId);
  }

  setMenuInteractive(enabled) {
    NavigationModule.setMenuInteractive(this.sceneId, enabled);
  }

  signalFirstRenderComplete() {
    NavigationModule.signalFirstRenderComplete(this.sceneId);
  }
}
