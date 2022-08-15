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
  static setStyle(style: DefaultOptions) {
    Navigation.setDefaultOptions(style)
  }

  static statusBarHeight() {
    return Navigation.statusBarHeight()
  }

  static toolbarHeight() {
    return Navigation.toolbarHeight()
  }

  static topBarHeight() {
    return Navigation.topBarHeight()
  }

  constructor(public sceneId: string) {}

  setLeftBarButtonItem(buttonItem: Nullable<BarButtonItem> | null) {
    Navigation.setLeftBarButtonItem(this.sceneId, buttonItem)
  }

  setRightBarButtonItem(buttonItem: Nullable<BarButtonItem> | null) {
    Navigation.setRightBarButtonItem(this.sceneId, buttonItem)
  }

  setLeftBarButtonItems(buttonItems: Array<Nullable<BarButtonItem>> | null) {
    Navigation.setLeftBarButtonItems(this.sceneId, buttonItems)
  }

  setRightBarButtonItems(buttonItems: Array<Nullable<BarButtonItem>> | null) {
    Navigation.setRightBarButtonItems(this.sceneId, buttonItems)
  }

  setTitleItem(titleItem: TitleItem) {
    Navigation.setTitleItem(this.sceneId, titleItem)
  }

  updateOptions(options: NavigationOption) {
    Navigation.updateOptions(this.sceneId, options)
  }

  updateTabBar(options: TabBarStyle) {
    Navigation.updateTabBar(this.sceneId, options)
  }

  setTabItem(item: TabItemInfo | TabItemInfo[]) {
    Navigation.setTabItem(this.sceneId, item)
  }

  setMenuInteractive(enabled: boolean) {
    Navigation.setMenuInteractive(this.sceneId, enabled)
  }
}
