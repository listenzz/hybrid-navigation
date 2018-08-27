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

  setTopBarStyle(item) {
    GardenModule.setTopBarStyle(this.sceneId, item);
  }

  setTopBarAlpha(item) {
    GardenModule.setTopBarAlpha(this.sceneId, item);
  }

  setTopBarColor(item) {
    GardenModule.setTopBarColor(this.sceneId, item);
  }

  setTopBarShadowHidden(item) {
    GardenModule.setTopBarShadowHidden(this.sceneId, item);
  }

  setTabBarColor(item) {
    GardenModule.setTabBarColor(this.sceneId, item);
  }

  replaceTabIcon(index, icon, inactiveIcon) {
    GardenModule.replaceTabIcon(this.sceneId, index, icon, inactiveIcon);
  }

  replaceTabColor(item) {
    GardenModule.replaceTabColor(this.sceneId, item);
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
