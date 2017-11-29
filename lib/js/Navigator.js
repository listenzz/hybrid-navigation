import Navigation from './NavigationModule';

export default class Navigator {

    constructor(navId, sceneId) {
        this.navId = navId;
        this.sceneId =sceneId;
    }

    push(moduleName, props={}, options={}, animated = true) {
        Navigation.push(this.navId, this.sceneId, moduleName, props, options, animated);
    }

    pop(animated = true) {
        Navigation.pop(this.navId, this.sceneId, animated);
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
