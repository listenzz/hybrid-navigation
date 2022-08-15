import { Platform } from 'react-native'

import type {
  BarButtonItem,
  DefaultOptions,
  NavigationOption,
  TabBarStyle,
  TabItemInfo,
  TitleItem,
} from './Options'
import type { BuildInLayout, Layout, RouteGraph, Route } from './Route'

import BarButtonEventHandler from './handler/BarButtonEventHandler'
import LayoutCommandHandler from './handler/LayoutCommandHandler'
import DispatchCommandHandler from './handler/DispatchCommandHandler'
import ResultEventHandler, { ResultType } from './handler/ResultEventHandler'
import VisibilityEventHandler, {
  GlobalVisibilityEventListener,
  VisibilityEventListener,
} from './handler/VisibilityEventHandler'

import Event from './Event'
import GardenModule from './GardenModule'
import NavigationModule from './NavigationModule'

export type { ResultType } from './handler/ResultEventHandler'
import type { DispatchParams, NavigationInterceptor } from './handler/DispatchCommandHandler'
export type { DispatchParams, NavigationInterceptor } from './handler/DispatchCommandHandler'

type BarButtonClickEventListener = (sceneId: string, value: Function) => void

type Nullable<T> = {
  [P in keyof T]: T[P] extends T[P] | undefined ? T[P] | null : T[P]
}

const { STATUSBAR_HEIGHT, TOOLBAR_HEIGHT } = GardenModule.getConstants()
export const { RESULT_CANCEL, RESULT_OK } = NavigationModule.getConstants()

export type NavigationSubscription = {
  remove: () => void
}

export interface Navigation {}

export class Navigation implements Navigation {
  private dispatchHandler = new DispatchCommandHandler()
  private resultHandler = new ResultEventHandler()
  private buttonHandler = new BarButtonEventHandler()
  private layoutHandler = new LayoutCommandHandler()
  private visibilityHandler = new VisibilityEventHandler()

  constructor() {
    this.handleStatusBarHeightChange()
    this.handleTabSwitch()
    this.layoutHandler.handleRootLayoutChange()
    this.visibilityHandler.handleComponentVisibility()
    this.resultHandler.handleComponentResult()
  }

  startRegisterReactComponent() {
    NavigationModule.startRegisterReactComponent()
  }

  endRegisterReactComponent() {
    NavigationModule.endRegisterReactComponent()
  }

  registerReactComponent(appKey: string, options: object) {
    NavigationModule.registerReactComponent(appKey, options)
  }

  addGlobalVisibilityEventListener(
    listener: GlobalVisibilityEventListener,
  ): NavigationSubscription {
    this.visibilityHandler.addGlobalVisibilityEventListener(listener)
    return {
      remove: () => this.visibilityHandler.removeGlobalVisibilityEventListener(listener),
    }
  }

  addVisibilityEventListener(
    sceneId: string,
    listener: VisibilityEventListener,
  ): NavigationSubscription {
    this.visibilityHandler.addVisibilityEventListener(sceneId, listener)
    return {
      remove: () => this.visibilityHandler.removeVisibilityEventListener(sceneId, listener),
    }
  }

  dispatch(sceneId: string, action: string, params: DispatchParams = {}) {
    return this.dispatchHandler.dispatch(sceneId, action, params)
  }

  private handleTabSwitch() {
    Event.listenTabSwitch((sceneId: string, from: number, to: number) => {
      this.dispatch(sceneId, 'switchTab', { from, to })
    })
  }

  setInterceptor(interceptor: NavigationInterceptor) {
    this.dispatchHandler.setInterceptor(interceptor)
  }

  setResult = <T extends ResultType>(
    sceneId: string,
    resultCode: number,
    data: T = null as any,
  ): void => NavigationModule.setResult(sceneId, resultCode, data)

  result<T>(sceneId: string, resultCode: number) {
    return this.resultHandler.waitResult<T>(sceneId, resultCode)
  }

  unmount(sceneId: string) {
    this.resultHandler.invalidateResultEventListener(sceneId)
    this.buttonHandler.unbindBarButtonClickEvent(sceneId)
  }

  setRoot(layout: BuildInLayout | Layout, sticky = false) {
    return this.layoutHandler.setRoot(layout, sticky)
  }

  setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    this.layoutHandler.setRootLayoutUpdateListener(willSetRoot, didSetRoot)
  }

  currentTab(sceneId: string) {
    return NavigationModule.currentTab(sceneId)
  }

  findSceneIdByModuleName(moduleName: string) {
    return NavigationModule.findSceneIdByModuleName(moduleName)
  }

  isStackRoot(sceneId: string) {
    return NavigationModule.isStackRoot(sceneId)
  }

  signalFirstRenderComplete(sceneId: string) {
    NavigationModule.signalFirstRenderComplete(sceneId)
  }

  currentRoute(): Promise<Route> {
    return NavigationModule.currentRoute()
  }

  routeGraph(): Promise<RouteGraph[]> {
    return NavigationModule.routeGraph()
  }

  setDefaultOptions(options: DefaultOptions) {
    GardenModule.setStyle(options)
  }

  setLeftBarButtonItem(sceneId: string, buttonItem: Nullable<BarButtonItem> | null) {
    const options = this.bindBarButtonClickEvent(sceneId, buttonItem)
    GardenModule.setLeftBarButtonItem(sceneId, options)
  }

  setRightBarButtonItem(sceneId: string, buttonItem: Nullable<BarButtonItem> | null) {
    const options = this.bindBarButtonClickEvent(sceneId, buttonItem)
    GardenModule.setRightBarButtonItem(sceneId, options)
  }

  setLeftBarButtonItems(sceneId: string, buttonItems: Array<Nullable<BarButtonItem>> | null) {
    const options = this.bindBarButtonClickEvent(sceneId, buttonItems)
    GardenModule.setLeftBarButtonItems(sceneId, options)
  }

  setRightBarButtonItems(sceneId: string, buttonItems: Array<Nullable<BarButtonItem>> | null) {
    const options = this.bindBarButtonClickEvent(sceneId, buttonItems)
    GardenModule.setRightBarButtonItems(sceneId, options)
  }

  setTitleItem(sceneId: string, titleItem: TitleItem) {
    GardenModule.setTitleItem(sceneId, titleItem)
  }

  updateOptions(sceneId: string, options: NavigationOption) {
    GardenModule.updateOptions(sceneId, options)
  }

  updateTabBar(sceneId: string, options: TabBarStyle) {
    GardenModule.updateTabBar(sceneId, options)
  }

  setTabItem(sceneId: string, item: TabItemInfo | TabItemInfo[]) {
    if (!Array.isArray(item)) {
      item = [item]
    }
    GardenModule.setTabItem(sceneId, item)
  }

  setMenuInteractive(sceneId: string, enabled: boolean) {
    GardenModule.setMenuInteractive(sceneId, enabled)
  }

  private _statusBarHeight = STATUSBAR_HEIGHT
  private _toolbarHeight = TOOLBAR_HEIGHT

  private handleStatusBarHeightChange() {
    if (Platform.OS === 'ios') {
      Event.listenStatusBarHeightChange(statusBarHeight => {
        this._statusBarHeight = statusBarHeight
      })
    }
  }

  statusBarHeight() {
    return this._statusBarHeight
  }

  toolbarHeight() {
    return this._toolbarHeight
  }

  topBarHeight() {
    return this.statusBarHeight() + this.toolbarHeight()
  }

  setBarButtonClickEventListener(listener: BarButtonClickEventListener) {
    this.buttonHandler.setBarButtonClickEventListener(listener)
  }

  bindBarButtonClickEvent(sceneId: string, item: object | null | undefined): object | null {
    return this.buttonHandler.bindBarButtonClickEvent(sceneId, item)
  }
}

export default new Navigation()
