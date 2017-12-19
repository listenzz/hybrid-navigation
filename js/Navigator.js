import Navigation from './NavigationModule';

export default class Navigator {

    constructor(navId, sceneId) {
        this.navId = navId;
        this.sceneId =sceneId;
        this.push = this.push.bind(this)
        this.pop = this.pop.bind(this)
        this.popTo = this.popTo.bind(this)
        this.popToRoot = this.popToRoot.bind(this)
        this.isRoot = this.isRoot.bind(this)
        this.present = this.present.bind(this)
        this.dismiss = this.dismiss.bind(this)
        this.replace = this.replace.bind(this)
        this.replaceToRoot = this.replaceToRoot.bind(this)
        this.setResult = this.setResult.bind(this)
    }

    push(moduleName, props={}, options={}, animated = true) {
        Navigation.push(this.navId, this.sceneId, moduleName, props, options, animated);
    }

    pop(animated = true) {
        Navigation.pop(this.navId, this.sceneId, animated);
    }

    popTo(sceneId, animated = true) {
        Navigation.popTo(this.navId, this.sceneId, sceneId, animated);
    }

    popToRoot(animated = true) {
        Navigation.popToRoot(this.navId, this.sceneId, animated);
    }

    isRoot() {
        return Navigation.isRoot(this.navId, this.sceneId);
    }

    replace(moduleName, props={}, options={}) {
        Navigation.replace(this.navId, this.sceneId, moduleName, props, options);
    }

    replaceToRoot(moduleName, props={}, options={}) {
        Navigation.replaceToRoot(this.navId, this.sceneId, moduleName, props, options);
    }

    present(moduleName, requestCode,  props={}, options={}, animated = true) {
        Navigation.present(this.navId, this.sceneId, moduleName, requestCode, props, options, animated);
    }

    dismiss(animated = true) {
        Navigation.dismiss(this.navId, this.sceneId, animated);
    }

    setResult(resultCode, data = {}) {
        Navigation.setResult(this.navId, this.sceneId, resultCode, data);
    }

    signalFirstRenderComplete() {
        Navigation.signalFirstRenderComplete(this.navId, this.sceneId);
    }

}

const RESULT_OK = -1;
const RESULT_CANCEL = 0;

export {
    RESULT_OK,
    RESULT_CANCEL,
}
