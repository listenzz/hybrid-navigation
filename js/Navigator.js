import Navigation from './NavigationModule';

export default class Navigator {

  /**
   * ```
   * {
   *  drawer: [ { tabs: [ {stack: 
   *                              { screen: "Home"} 
   *                      }, 
   *                      { stack: 
   *                              { screen: "Profile"} 
   *                      }, 
   *                    ]
   *            }, 
   *            { screen: "Setting"}
   *          ]
   * }
   * ```
   */
  static setRoot(layout) {
    console.info('root:' + JSON.stringify(layout));
    Navigation.setRoot(layout);
  }

  constructor(sceneId) {
    this.sceneId = sceneId;
    this.push = this.push.bind(this)
    this.pop = this.pop.bind(this)
    this.popTo = this.popTo.bind(this)
    this.popToRoot = this.popToRoot.bind(this)
    this.isRoot = this.isRoot.bind(this)
    this.present = this.present.bind(this)
    this.setResult = this.setResult.bind(this)
    this.dismiss = this.dismiss.bind(this)
    this.replace = this.replace.bind(this)
    this.replaceToRoot = this.replaceToRoot.bind(this)
    this.onBarButtonItemClick = undefined;
    this.onComponentResult = undefined;
  }

  push(moduleName, props={}, options={}, animated = true) {
    Navigation.push(this.sceneId, moduleName, props, options, animated);
  }

  pop(animated = true) {
    Navigation.pop(this.sceneId, animated);
  }

  popTo(sceneId, animated = true) {
    Navigation.popTo(this.sceneId, sceneId, animated);
  }

  popToRoot(animated = true) {
    Navigation.popToRoot(this.sceneId, animated);
  }

  isRoot() {
    return Navigation.isRoot(this.sceneId);
  }

  replace(moduleName, props={}, options={}) {
    Navigation.replace(this.sceneId, moduleName, props, options);
  }

  replaceToRoot(moduleName, props={}, options={}) {
    Navigation.replaceToRoot(this.sceneId, moduleName, props, options);
  }

  present(moduleName, requestCode,  props={}, options={}, animated = true) {
    Navigation.present(this.sceneId, moduleName, requestCode, props, options, animated);
  }

  setResult(resultCode, data = {}) {
    Navigation.setResult(this.sceneId, resultCode, data);
  }

  dismiss(animated = true) {
    Navigation.dismiss(this.sceneId, animated);
  }

  switchToTab(index) {
    Navigation.switchToTab(this.sceneId, index);
  }

  setTabBadge(index, text) {
    Navigation.setTabBadge(this.sceneId, index, text);
  }

  toggleMenu() {
    Navigation.toggleMenu(this.sceneId);
  }

  openMenu() {
    Navigation.openMenu(this.sceneId);
  }

  closeMenu() {
    Navigation.closeMenu(this.sceneId);
  }

  signalFirstRenderComplete() {
    Navigation.signalFirstRenderComplete(this.sceneId);
  }

}
