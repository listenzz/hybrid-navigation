import { NativeModules } from 'react-native';

const GardenModule = NativeModules.GardenHybrid;
export default class Garden {
    constructor(navId, sceneId) {
        this.navId = navId;
        this.sceneId =sceneId;
    }

    static setTopBarStyle(style) {
        GardenModule.setTopBarStyle(style);
    }

    static setStatusBarColor(color) {
        GardenModule.setStatusBarColor(color);
    }

    static setHideBackTitle(hidden) {
        GardenModule.setHideBackTitle(hidden);
    }

    static setBackIcon(icon) {
        GardenModule.setBackIcon(icon);
    }

    static setTopBarBackgroundColor(color) {
        GardenModule.setTopBarBackgroundColor(color);
    }

    static setTopBarTintColor(color) {
        GardenModule.setTopBarTintColor(color);
    }

    static setTitleTextColor(color) {
        GardenModule.setTitleTextColor(color);
    }

    static setTitleTextSize(dp) {
        GardenModule.setTitleTextSizeDp(dp);
    }

    static setTitleAlignment(alignment) {
        GardenModule.setTitleAlignment(alignment);
    }

    static setBarButtonItemTintColor(color) {
        GardenModule.setBarButtonItemTintColor(color);
    }

    static setBarButtonItemTextSize(dp) {
        GardenModule.setBarButtonItemTextSizeDp(dp);
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

const TOP_BAR_STYLE_LIGHT_CONTENT = 'light-content';
const TOP_BAR_STYLE_DARK_CONTENT = 'dark-content';
const TITLE_ALIGNMENT_LEFT = 'left';
const TITLE_ALIGNMENT_CENTER = 'center'; 

export {
    TOP_BAR_STYLE_LIGHT_CONTENT,
    TOP_BAR_STYLE_DARK_CONTENT,
    TITLE_ALIGNMENT_LEFT,
    TITLE_ALIGNMENT_CENTER
}