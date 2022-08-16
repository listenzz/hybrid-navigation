import Navigation from './Navigation'
import type {
  BarButtonItem,
  DefaultOptions,
  NavigationOption,
  TabBarStyle,
  TabItemInfo,
  TitleItem,
} from './Options'

type Nullable<T> = {
  [P in keyof T]: T[P] extends T[P] | undefined ? T[P] | null : T[P]
}

export interface Garden {}
export class Garden implements Garden {
  /**
   * @deprecated Use Navigation.setDefaultOptions() instead.
   * @param style
   */
  static setStyle(style: DefaultOptions) {
    Navigation.setDefaultOptions(style)
  }

  constructor(public sceneId: string) {}

  /**
   * @deprecated Use Navigation.setLeftBarButtonItem() instead.
   * @param buttonItem
   */
  setLeftBarButtonItem(buttonItem: Nullable<BarButtonItem> | null) {
    Navigation.setLeftBarButtonItem(this.sceneId, buttonItem)
  }

  /**
   * @deprecated Use Navigation.setRightBarButtonItem() instead.
   * @param buttonItem
   */
  setRightBarButtonItem(buttonItem: Nullable<BarButtonItem> | null) {
    Navigation.setRightBarButtonItem(this.sceneId, buttonItem)
  }

  /**
   *
   * @deprecated Use Navigation.setLeftBarButtonItems() instead.
   * @param buttonItems
   */
  setLeftBarButtonItems(buttonItems: Array<Nullable<BarButtonItem>> | null) {
    Navigation.setLeftBarButtonItems(this.sceneId, buttonItems)
  }

  /**
   * @deprecated Use Navigation.setRightBarButtonItems() instead.
   * @param buttonItems
   */
  setRightBarButtonItems(buttonItems: Array<Nullable<BarButtonItem>> | null) {
    Navigation.setRightBarButtonItems(this.sceneId, buttonItems)
  }

  /**
   * @deprecated Use Navigation.setTitleItem() instead.
   * @param titleItem
   */
  setTitleItem(titleItem: TitleItem) {
    Navigation.setTitleItem(this.sceneId, titleItem)
  }

  /**
   * @deprecated Use Navigation.updateOptions() instead.
   * @param options
   */
  updateOptions(options: NavigationOption) {
    Navigation.updateOptions(this.sceneId, options)
  }

  /**
   * @deprecated Use Navigation.updateTabBar() instead.
   * @param options
   */
  updateTabBar(options: TabBarStyle) {
    Navigation.updateTabBar(this.sceneId, options)
  }

  /**
   * @deprecated Use Navigation.setTabItem() instead.
   * @param item
   */
  setTabItem(item: TabItemInfo | TabItemInfo[]) {
    Navigation.setTabItem(this.sceneId, item)
  }

  /**
   * @deprecated Use Navigation.setMenuInteractive() instead.
   * @param enabled
   */
  setMenuInteractive(enabled: boolean) {
    Navigation.setMenuInteractive(this.sceneId, enabled)
  }
}
