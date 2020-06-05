import { Platform } from 'react-native'
import {
  EventEmitter,
  NavigationModule,
  EVENT_WILL_SET_ROOT,
  EVENT_DID_SET_ROOT,
  EVENT_SWITCH_TAB,
  KEY_SCENE_ID,
  KEY_INDEX,
  KEY_MODULE_NAME,
  RESULT_CANCEL,
} from './NavigationModule'
import { bindBarButtonItemClickEvent } from './utils'
import store from './store'
import { NavigationItem } from './Garden'
import { Route, RouteGraph } from './router'
import { Visibility } from './hooks'

export interface IndexType {
  [index: string]: any
}

interface Extras {
  sceneId: string
  index?: number
}

interface Params {
  animated?: boolean
  moduleName?: string
  layout?: Layout
  index?: number
  popToRoot?: boolean
  targetId?: string
  requestCode?: number
  props?: IndexType
  options?: NavigationItem
  [index: string]: any
}

interface NavigationState {
  params: { readonly [index: string]: any }
  unmountListeners: UnmountListener[]
  resultListeners: ResultListener<any>[]
}

export interface NavigationInterceptor {
  (action: string, from?: string, to?: string, extras?: Extras): boolean
}

type ResultType = IndexType | null

interface ResultListener<T extends ResultType> {
  (requestCode: number, resultCode: number, data: T): void
  cancel: () => void
}

type Result<T> = [number, T]

interface UnmountListener {
  (): void
}

export interface Layout {
  [index: string]: {}
}

export interface Screen extends Layout {
  screen: {
    moduleName: string
    props?: IndexType
    options?: NavigationItem
  }
}

export interface Stack extends Layout {
  stack: {
    children: Layout[]
    options?: {}
  }
}

export interface Tabs extends Layout {
  tabs: {
    children: Layout[]
    options?: {
      selectedIndex?: number
      tabBarModuleName?: string
      sizeIndeterminate?: boolean
    }
  }
}

export interface Drawer extends Layout {
  drawer: {
    children: [Layout, Layout]
    options?: {
      maxDrawerWidth?: number
      minDrawerMargin?: number
      menuInteractive?: boolean
    }
  }
}

let intercept: NavigationInterceptor
let shouldCallWillSetRootCallback = 0
let willSetRootCallback: () => void
let didSetRootCallback: () => void
let tag = 0

EventEmitter.addListener(EVENT_DID_SET_ROOT, (_) => {
  didSetRootCallback && didSetRootCallback()
  shouldCallWillSetRootCallback = 0
})

EventEmitter.addListener(EVENT_WILL_SET_ROOT, (_) => {
  if (shouldCallWillSetRootCallback === 0 && willSetRootCallback) {
    willSetRootCallback()
  }
})

EventEmitter.addListener(EVENT_SWITCH_TAB, (event) => {
  Navigator.dispatch(event[KEY_SCENE_ID], 'switchTab', {
    index: event[KEY_INDEX],
    moduleName: event[KEY_MODULE_NAME],
  })
})

export function reload() {
  NavigationModule.reload()
}

export function delay(ms: number): Promise<{}> {
  return NavigationModule.delay(ms)
}

export function foreground(): Promise<void> {
  if (Platform.OS === 'android') {
    return NavigationModule.foreground()
  } else {
    return Promise.resolve()
  }
}

function checkRequestCode(reqCode?: number) {
  if (reqCode === undefined) {
    return --tag
  }

  if (reqCode < 0) {
    throw new Error('`requestCode` must be positive.')
  }

  return reqCode
}

export class Navigator {
  static get(sceneId: string): Navigator {
    return store.getNavigator(sceneId) || new Navigator(sceneId)
  }

  static async current(): Promise<Navigator> {
    const route = await Navigator.currentRoute()
    return Navigator.get(route.sceneId)
  }

  static async currentRoute(): Promise<Route> {
    await foreground()
    return await NavigationModule.currentRoute()
  }

  static async routeGraph(): Promise<RouteGraph[]> {
    await foreground()
    return await NavigationModule.routeGraph()
  }

  static setRoot(layout: Layout, sticky = false) {
    const pureLayout = bindBarButtonItemClickEvent(layout, {
      inLayout: true,
      navigatorFactory: (sceneId: string) => {
        return Navigator.get(sceneId)
      },
    })
    if (willSetRootCallback) {
      shouldCallWillSetRootCallback++
      willSetRootCallback()
    }

    const flag = --tag
    NavigationModule.setRoot(pureLayout, sticky, flag)

    return new Promise<void>((resolve) => {
      const subscription = EventEmitter.addListener(EVENT_DID_SET_ROOT, (data: { tag: number }) => {
        if (data.tag === flag) {
          subscription.remove()
          resolve()
        }
      })
    })
  }

  static setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    willSetRootCallback = willSetRoot
    didSetRootCallback = didSetRoot
  }

  static async dispatch(sceneId: string, action: string, params: Params = {}): Promise<boolean> {
    await foreground()
    const navigator = Navigator.get(sceneId)
    if (
      !intercept ||
      !intercept(action, navigator.moduleName, params.moduleName, {
        sceneId,
        index: params.index,
      })
    ) {
      NavigationModule.dispatch(sceneId, action, params)
      return true
    }
    return false
  }

  static setInterceptor(interceptor: NavigationInterceptor) {
    intercept = interceptor
  }

  visibility: Visibility = 'pending'

  constructor(public sceneId: string, public moduleName?: string) {
    this.sceneId = sceneId
    this.moduleName = moduleName
    this.dispatch = this.dispatch.bind(this)
    this.setParams = this.setParams.bind(this)

    this.push = this.push.bind(this)
    this.pop = this.pop.bind(this)
    this.popTo = this.popTo.bind(this)
    this.popToRoot = this.popToRoot.bind(this)
    this.redirectTo = this.redirectTo.bind(this)
    this.isStackRoot = this.isStackRoot.bind(this)

    this.present = this.present.bind(this)
    this.dismiss = this.dismiss.bind(this)
    this.showModal = this.showModal.bind(this)
    this.hideModal = this.hideModal.bind(this)
    this.setResult = this.setResult.bind(this)

    this.toggleMenu = this.toggleMenu.bind(this)
    this.openMenu = this.openMenu.bind(this)
    this.closeMenu = this.closeMenu.bind(this)
  }

  state: NavigationState = {
    params: {},
    unmountListeners: [],
    resultListeners: [],
  }

  setParams(params: { [index: string]: any }) {
    this.state.params = { ...this.state.params, ...params }
  }

  dispatch(action: string, params: Params = {}) {
    return Navigator.dispatch(this.sceneId, action, params)
  }

  result(requestCode: number, resultCode: number, data: ResultType) {
    this.state.resultListeners.forEach((listener) => {
      listener(requestCode, resultCode, data)
    })
  }

  unmount() {
    this.state.resultListeners.forEach((listener) => {
      listener.cancel()
    })
    this.state.resultListeners.length = 0

    this.state.unmountListeners.forEach((listener) => {
      listener()
    })
    this.state.unmountListeners.length = 0
  }

  private waitResult<T extends ResultType>(
    requestCode: number,
    successful: boolean,
  ): Promise<Result<T>> {
    if (!successful) {
      return Promise.resolve([0, null as any])
    }
    return new Promise<Result<T>>((resolve) => {
      const listener = (reqCode: number, resultCode: number, data: T) => {
        if (requestCode === reqCode) {
          resolve([resultCode, data])
          const index = this.state.resultListeners.indexOf(listener)
          if (index !== -1) {
            this.state.resultListeners.splice(index, 1)
          }
        }
      }

      listener.cancel = () => {
        resolve([RESULT_CANCEL, null as any])
      }
      this.state.resultListeners.push(listener)
    })
  }

  private waitUnmount(successful: boolean): Promise<void> {
    if (!successful) {
      return Promise.resolve()
    }

    if (this.moduleName) {
      return new Promise<void>((resolve) => {
        this.state.unmountListeners.push(() => {
          resolve()
        })
      })
    } else {
      return Promise.resolve()
    }
  }

  async push<T extends ResultType = any, P extends IndexType = {}>(
    moduleName: string,
    props: P = {} as any,
    options: NavigationItem = {},
  ) {
    const success = await this.dispatch('push', { moduleName, props, options })
    return await this.waitResult<T>(0, success)
  }

  async pushLayout<T extends ResultType = any>(layout: Layout) {
    const success = await this.dispatch('pushLayout', { layout })
    return await this.waitResult<T>(0, success)
  }

  async pop() {
    const success = await this.dispatch('pop')
    return await this.waitUnmount(success)
  }

  async popTo(sceneId: string) {
    const success = await this.dispatch('popTo', { targetId: sceneId })
    if (sceneId === this.sceneId) {
      return
    }
    return await this.waitUnmount(success)
  }

  async popToRoot() {
    const isRoot = await this.isStackRoot()
    const success = await this.dispatch('popToRoot')
    if (isRoot) {
      return
    }
    return await this.waitUnmount(success)
  }

  async redirectTo<P extends IndexType = {}>(
    moduleName: string,
    props: P = {} as any,
    options: NavigationItem = {},
  ) {
    const success = await this.dispatch('redirectTo', {
      moduleName,
      props,
      options,
      animated: true,
    })
    return await this.waitUnmount(success)
  }

  isStackRoot(): Promise<boolean> {
    return NavigationModule.isNavigationRoot(this.sceneId)
  }

  async present<T extends ResultType = any, P extends IndexType = {}>(
    moduleName: string,
    props: P = {} as any,
    options: NavigationItem = {},
    requestCode?: number,
  ) {
    requestCode = checkRequestCode(requestCode)
    const success = await this.dispatch('present', {
      moduleName,
      props,
      options,
      requestCode,
    })
    return await this.waitResult<T>(requestCode, success)
  }

  async presentLayout<T extends ResultType = any>(layout: Layout, requestCode?: number) {
    requestCode = checkRequestCode(requestCode)
    const success = await this.dispatch('presentLayout', { layout, requestCode })
    return await this.waitResult<T>(requestCode, success)
  }

  async dismiss() {
    const success = await this.dispatch('dismiss')
    return await this.waitUnmount(success)
  }

  async showModal<T extends ResultType = any, P extends IndexType = {}>(
    moduleName: string,
    props: P = {} as any,
    options: NavigationItem = {},
    requestCode?: number,
  ) {
    requestCode = checkRequestCode(requestCode)
    const success = await this.dispatch('showModal', {
      moduleName,
      props,
      options,
      requestCode,
    })
    return await this.waitResult<T>(requestCode, success)
  }

  async showModalLayout<T extends ResultType = any>(layout: Layout, requestCode?: number) {
    requestCode = checkRequestCode(requestCode)
    const success = await this.dispatch('showModalLayout', { layout, requestCode })
    return await this.waitResult<T>(requestCode, success)
  }

  async hideModal() {
    const success = await this.dispatch('hideModal')
    return await this.waitUnmount(success)
  }

  setResult<T extends ResultType = any>(resultCode: number, data: T = null as any): void {
    NavigationModule.setResult(this.sceneId, resultCode, data)
  }

  async switchTab(index: number, popToRoot: boolean = false) {
    await this.dispatch('switchTab', { index, popToRoot })
  }

  async toggleMenu() {
    await this.dispatch('toggleMenu')
  }

  async openMenu() {
    await this.dispatch('openMenu')
  }

  async closeMenu() {
    await this.dispatch('closeMenu')
  }

  signalFirstRenderComplete(): void {
    NavigationModule.signalFirstRenderComplete(this.sceneId)
  }
}
