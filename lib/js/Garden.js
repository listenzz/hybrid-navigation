import { NativeModules } from 'react-native';

const GardenModule = NativeModules.GardenHybrid;

export default class Garden {
    constructor(navId, sceneId) {
        this.navId = navId;
        this.sceneId =sceneId;
    }

    setLeftBarButtonItem(item) {
        GardenModule.setLeftBarButtonItem(this.navId, this.sceneId, item);
    }

}