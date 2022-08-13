import { Platform } from 'react-native'
import GardenModule from './GardenModule'
import Event from './Event'
import {
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

const { STATUSBAR_HEIGHT, TOOLBAR_HEIGHT } = GardenModule.getConstants()

if (Platform.OS === 'ios') {
  Event.listenStatusBarHeightChanged(statusBarHeight => {
    Garden.statusBarHeight = statusBarHeight
    Garden.topBarHeight = statusBarHeight + TOOLBAR_HEIGHT
  })
}

export class Garden {
  static setStyle(style: DefaultOptions = {}) {
    GardenModule.setStyle(style)
  }

  static statusBarHeight: number = STATUSBAR_HEIGHT
  static toolbarHeight: number = TOOLBAR_HEIGHT
  static topBarHeight: number = TOOLBAR_HEIGHT + STATUSBAR_HEIGHT

  constructor(public sceneId: string) {}

  // --------------- instance method --------------

  setLeftBarButtonItem(buttonItem: Nullable<BarButtonItem> | null) {
    const options = Event.bindBarButtonClickEvent(this.sceneId, buttonItem)
    GardenModule.setLeftBarButtonItem(this.sceneId, options)
  }

  setRightBarButtonItem(buttonItem: Nullable<BarButtonItem> | null) {
    const options = Event.bindBarButtonClickEvent(this.sceneId, buttonItem)
    GardenModule.setRightBarButtonItem(this.sceneId, options)
  }

  setLeftBarButtonItems(buttonItems: Array<Nullable<BarButtonItem>> | null) {
    const options = Event.bindBarButtonClickEvent(this.sceneId, buttonItems)
    GardenModule.setLeftBarButtonItems(this.sceneId, options)
  }

  setRightBarButtonItems(buttonItems: Array<Nullable<BarButtonItem>> | null) {
    const options = Event.bindBarButtonClickEvent(this.sceneId, buttonItems)
    GardenModule.setRightBarButtonItems(this.sceneId, options)
  }

  setTitleItem(titleItem: TitleItem) {
    GardenModule.setTitleItem(this.sceneId, titleItem)
  }

  updateOptions(options: NavigationOption) {
    GardenModule.updateOptions(this.sceneId, options)
  }

  updateTabBar(options: TabBarStyle) {
    GardenModule.updateTabBar(this.sceneId, options)
  }

  setTabItem(item: TabItemInfo | TabItemInfo[]) {
    if (!Array.isArray(item)) {
      item = [item]
    }
    GardenModule.setTabItem(this.sceneId, item)
  }

  setMenuInteractive(enabled: boolean) {
    GardenModule.setMenuInteractive(this.sceneId, enabled)
  }
}
