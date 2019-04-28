import { NativeModules, Platform } from 'react-native';
const GardenModule = NativeModules.GardenHybrid;
import { bindBarButtonItemClickEvent } from './utils';
export const BarStyleLightContent = 'light-content';
export const BarStyleDarkContent = 'dark-content';
export const TitleAlignmentLeft = 'left';
export const TitleAlignmentCenter = 'center';
export const LayoutFittingExpanded = 'expanded';
export const LayoutFittingCompressed = 'compressed';
export class Garden {
    constructor(sceneId) {
        this.sceneId = sceneId;
        this.sceneId = sceneId;
    }
    static setStyle(style = {}) {
        GardenModule.setStyle(style);
    }
    // --------------- instance method --------------
    setStatusBarColorAndroid(options) {
        if (Platform.OS === 'android') {
            GardenModule.setStatusBarColor(this.sceneId, options);
        }
    }
    setStatusBarHidden(hidden = true) {
        GardenModule.setStatusBarHidden(this.sceneId, { statusBarHidden: hidden });
    }
    setPassThroughTouches(item) {
        GardenModule.setPassThroughtouches(item);
    }
    setLeftBarButtonItem(buttonItem = {}) {
        const options = bindBarButtonItemClickEvent(buttonItem, { sceneId: this.sceneId });
        GardenModule.setLeftBarButtonItem(this.sceneId, options);
    }
    setRightBarButtonItem(buttonItem) {
        const options = bindBarButtonItemClickEvent(buttonItem, { sceneId: this.sceneId });
        GardenModule.setRightBarButtonItem(this.sceneId, options);
    }
    setTitleItem(item) {
        GardenModule.setTitleItem(this.sceneId, item);
    }
    updateTopBar(item = {}) {
        GardenModule.updateTopBar(this.sceneId, item);
    }
    updateTabBar(options = {}) {
        GardenModule.updateTabBar(this.sceneId, options);
    }
    replaceTabIcon(index, icon, inactiveIcon) {
        GardenModule.replaceTabIcon(this.sceneId, index, icon, inactiveIcon);
    }
    setTabBadgeText(index, text) {
        GardenModule.setTabBadgeText(this.sceneId, index, text);
    }
    setTabBadge(index, text) {
        console.warn('`setTabBadge` has been deprecated and will be removed in the next release, please use `setTabBadgeText`');
        GardenModule.setTabBadgeText(this.sceneId, index, text);
    }
    showRedPointAtIndex(index) {
        GardenModule.showRedPointAtIndex(index, this.sceneId);
    }
    hideRedPointAtIndex(index) {
        GardenModule.hideRedPointAtIndex(index, this.sceneId);
    }
    setMenuInteractive(enabled) {
        GardenModule.setMenuInteractive(this.sceneId, enabled);
    }
}
Garden.toolbarHeight = GardenModule.TOOLBAR_HEIGHT;
Garden.DARK_CONTENT = GardenModule.DARK_CONTENT;
Garden.LIGHT_CONTENT = GardenModule.LIGHT_CONTENT;
