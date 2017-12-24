import { NativeModules } from 'react-native';

const GardenModule = NativeModules.GardenHybrid;
export default class Garden {
    constructor(navId, sceneId) {
        this.navId = navId;
        this.sceneId =sceneId;
    }

    static setStyle(style = {}) {
        GardenModule.setStyle(style);
    }

    // --------------- instance method --------------

    setLeftBarButtonItem(item) {
        GardenModule.setLeftBarButtonItem(this.navId, this.sceneId, item);
    }

    setRightBarButtonItem(item) {
        GardenModule.setRightBarButtonItem(this.navId, this.sceneId, item);
    }

    setTitleItem(item) {
        GardenModule.setTitleItem(item);
    }

}