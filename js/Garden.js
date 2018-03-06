/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import { NativeModules } from 'react-native';

const GardenModule = NativeModules.GardenHybrid;
export default class Garden {
  constructor(sceneId) {
    this.sceneId = sceneId;
  }

  /**
   *
   * 全局配置 App 主题样式，以下是可配置项
   *
   * ```
   * {
   *  screenBackgroundColor: String // 页面背景，支持 #RRGGBB 格式的色值
   *  topBarStyle: String // 状态栏和导航栏前景色，可选值有 light-content 和 dark-content
   *  topBarColor: String // 顶部导航栏背景颜色
   *  statusBarColor: String // 状态栏背景色，仅对 Android 5.0 以上版本生效
   *  hideBackTitle: Bool // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
   *  elevation: Number // 导航栏阴影高度， 仅对 Android 5.0 以上版本生效，默认值为 4 dp
   *  shadowImage: Object // 导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效
   *  backIcon: Object // 返回按钮图标，需要传递一个带有 uri 和其它字段的对象
   *  topBarTintColor: String // 顶部导航栏标题和按钮的颜色
   *  titleTextColor: String // 顶部导航栏标题颜色
   *  titleTextSize: Int // 顶部导航栏标题字体大小，默认是 17 dp(pt)
   *  titleAlignment: String // 顶部导航栏标题的位置，有 left 和 center 两个值可选，默认是 left
   *  barButtonItemTintColor: String // 顶部导航栏按钮颜色
   *  barButtonItemTextSize: Int // 顶部导航栏按钮字体大小，默认是 15 dp(pt)
   *
   *  // BottomBar
   *  bottomBarBackgroundColor: String // 底部 TabBar 背景
   *  bottomBarShadowImage: Object // 底部 TabBar 阴影图片，仅对 iOS 和 Android 4.4 以下版本生效 ，对 iOS, 只有设置了 bottomBarBackgroundColor 才会生效
   *  bottomBarButtonItemActiveColor: String // 底部 TabBarItem 选中效果
   *  bottomBarButtonItemInActiveColor: String // 底部 TabBarItem 未选中效果
   *
   * }
   * ```
   */
  static setStyle(style = {}) {
    GardenModule.setStyle(style);
  }

  // --------------- instance method --------------

  /**
   *
   * 设置导航栏左侧按钮，这里的参数会被合并到 navigationItem
   *
   * ```
   * {
   *  title: String,
   *  icon: { uri: 'file://...'},
   *  enabled: Bool,
   *  action: String
   * }
   * ```
   */
  setLeftBarButtonItem(item) {
    GardenModule.setLeftBarButtonItem(this.sceneId, item);
  }

  /**
   *
   * 更改导航栏右侧按钮，这里的参数会被合并到 navigationItem
   *
   * ```
   * {
   *  title: String,
   *  icon: Image.resolveAssetSource(require('./ic_settings.png')),
   *  enabled: Bool,
   *  action: String
   * }
   * ```
   */
  setRightBarButtonItem(item) {
    GardenModule.setRightBarButtonItem(this.sceneId, item);
  }

  /**
   *
   * 设置导航栏标题，这里的值会被合并到 navigationItem
   *
   * ```
   * {
   *   title: String,
   * }
   * ```
   * @param {*} item
   */
  setTitleItem(item) {
    GardenModule.setTitleItem(this.sceneId, item);
  }

  /**
   *
   * 设置 TopBar 样式
   *
   * ```
   * {
   *   topBarStyle: 'dark-content'
   * }
   * ```
   * @param {*} item
   */
  setTopBarStyle(item) {
    GardenModule.setTopBarStyle(this.sceneId, item);
  }

  /**
   *
   * 设置状态栏背景颜色，仅对 Android 生效
   *
   * ```
   * {
   *   statusBarColor: '#FFFFFF'
   * }
   * ```
   * @param {*} item
   */
  setStatusBarColor(item) {
    GardenModule.setStatusBarColor(this.sceneId, item);
  }

  /**
   *
   * 设置 TopBar 背景的 alpha 值[0-1.0]，但 TopBar 上的控件仍清晰可见
   *
   * ```
   * {
   *   topBarAlpha: 0.5
   * }
   * ```
   * @param {*} item
   */
  setTopBarAlpha(item) {
    GardenModule.setTopBarAlpha(this.sceneId, item);
  }

  /**
   *
   * 设置 TopBar 背景颜色，这会覆盖全局设置的 topBarBackgroundColor
   *
   * ```
   * {
   *   topBarColor: '#FFFFFF'
   * }
   * ```
   * @param {*} item
   */
  setTopBarColor(item) {
    GardenModule.setTopBarColor(this.sceneId, item);
  }

  /**
   *
   * 设置是否隐藏 TopBar 阴影
   *
   * ```
   * {
   *   topBarShadowHidden: true
   * }
   * ```
   * @param {*} item
   */
  setTopBarShadowHidden(item) {
    GardenModule.setTopBarShadowHidden(this.sceneId, item);
  }
}
