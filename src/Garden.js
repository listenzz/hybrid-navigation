import { NativeModules, Platform } from 'react-native';
const GardenModule = NativeModules.GardenHybrid;
import { bindBarButtonItemClickEvent } from './utils';

export default class Garden {
  static toolbarHeight = GardenModule.TOOLBAR_HEIGHT;
  static DARK_CONTENT = GardenModule.DARK_CONTENT;
  static LIGHT_CONTENT = GardenModule.LIGHT_CONTENT;

  static setStyle(style = {}) {
    GardenModule.setStyle(style);
    if (style.toolbarHeight) {
      toolbarHeight = Number(style.toolbarHeight);
    }
  }

  constructor(sceneId) {
    this.sceneId = sceneId;
  }

  // --------------- instance method --------------

  setStatusBarColor(item) {
    this.setStatusBarColorAndroid(item);
    console.warn(`setStatusBarColor 已经弃用，请使用 setStatusBarColorAndroid`);
  }

  setStatusBarColorAndroid(item) {
    if (Platform.OS === 'android') {
      GardenModule.setStatusBarColor(this.sceneId, item);
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

  updateTopBar(options = {}) {
    GardenModule.updateTopBar(this.sceneId, options);
  }

  updateTabBar(options = {}) {
    GardenModule.updateTabBar(this.sceneId, options);
  }

  replaceTabIcon(index, icon, inactiveIcon) {
    GardenModule.replaceTabIcon(this.sceneId, index, icon, inactiveIcon);
  }

  setTabBadge(index, text) {
    GardenModule.setTabBadge(this.sceneId, index, text);
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
