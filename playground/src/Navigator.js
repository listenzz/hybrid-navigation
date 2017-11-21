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

    present(moduleName, requestCode,  props={}, options={}, animated = true) {
        Navigation.present(this.navId, this.sceneId, moduleName, requestCode, props, options, animated);
    }

    dismiss(animated = true) {
        Navigation.dismiss(this.navId, this.sceneId, animated);
    }

    setResult(resultCode, data = {}) {
        Navigation.setResult(this.navId, this.sceneId, resultCode, data);
    }

}
