import { NativeModules } from 'react-native';
const GardenModule = NativeModules.GardenHybrid;

function copy(obj = {}) {
  let target = {};
  for (const key of Object.keys(obj)) {
    const value = obj[key];
    if (value && typeof value === 'object') {
      target[key] = copy(value);
    } else {
      target[key] = value;
    }
  }
  return target;
}

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

  constructor(sceneId, options) {
    this.sceneId = sceneId;
    this.options = options;
  }

  // --------------- instance method --------------

  setStatusBarColor(item) {
    GardenModule.setStatusBarColor(this.sceneId, item);
  }

  setStatusBarHidden(hidden = true) {
    GardenModule.setStatusBarHidden(this.sceneId, { statusBarHidden: hidden });
  }

  setPassThroughTouches(item) {
    GardenModule.setPassThroughtouches(item);
  }

  setLeftBarButtonItem(item) {
    if (this.options.leftBarButtonItem) {
      this.options.leftBarButtonItem = { ...this.options.leftBarButtonItem, ...item };
    } else {
      this.options.leftBarButtonItem = item;
    }

    const buttonItem = copy(item);

    if (typeof buttonItem.action === 'function') {
      buttonItem.action = 'left_bar_button_item_click';
    }

    GardenModule.setLeftBarButtonItem(this.sceneId, buttonItem);
  }

  setRightBarButtonItem(item) {
    if (this.options.rightBarButtonItem) {
      this.options.rightBarButtonItem = { ...this.options.rightBarButtonItem, ...item };
    } else {
      this.options.rightBarButtonItem = item;
    }

    const buttonItem = copy(item);
    if (typeof buttonItem.action === 'function') {
      buttonItem.action = 'right_bar_button_item_click';
    }

    GardenModule.setRightBarButtonItem(this.sceneId, buttonItem);
  }

  setTitleItem(item) {
    GardenModule.setTitleItem(this.sceneId, item);
  }

  updateTopBar(options = {}) {
    GardenModule.updateTopBar(this.sceneId, options);
  }

  setTitleTextAttributes(attributes) {
    console.warn('#setTitleTextAttributes 已经弃用，请使用 #updateTopBar');
    this.updateTopBar(attributes);
  }

  setTopBarStyle(item) {
    console.warn('#setTopBarStyle 已经弃用，请使用 #updateTopBar');
    this.updateTopBar(item);
  }

  setTopBarTintColor(item) {
    console.warn('#setTopBarTintColor 已经弃用，请使用 #updateTopBar');
    this.updateTopBar(item);
  }

  setTopBarAlpha(item) {
    console.warn('#setTopBarAlpha 已经弃用，请使用 #updateTopBar');
    this.updateTopBar(item);
  }

  setTopBarColor(item) {
    console.warn('#setTopBarColor 已经弃用，请使用 #updateTopBar');
    this.updateTopBar(item);
  }

  setTopBarShadowHidden(item) {
    console.warn('#setTopBarShadowHidden 已经弃用，请使用 #updateTopBar');
    this.updateTopBar(item);
  }

  updateTabBar(options = {}) {
    GardenModule.updateTabBar(this.sceneId, options);
  }

  setTabBarColor(item) {
    console.warn('#setTabBarColor 已经弃用，请使用 #updateTabBar');
    this.updateTabBar(item);
  }

  replaceTabColor(item) {
    console.warn('#replaceTabColor 已经弃用，请使用 #updateTabBar');
    this.updateTabBar(item);
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
