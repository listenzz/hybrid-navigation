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
} from './NavigationModule'
import { bindBarButtonItemClickEvent } from './utils'
import store from './store'
import { NavigationItem } from './Garden'
import { Route, RouteGraph } from './router'
import { Visibility } from './hooks'

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
  props?: { [index: string]: any }
  options?: NavigationItem
  [index: string]: any
}

interface NavigationState {
  params: { readonly [index: string]: any }
  unmountListeners: UnmountListener[]
  resultListeners: ResultListener[]
}

export interface NavigationInterceptor {
  (action: string, from?: string, to?: string, extras?: Extras): boolean
}

interface ResultListener {
  (requestCode: number, resultCode: number, data: any): void
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
    props?: { [index: string]: any }
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

EventEmitter.addListener(EVENT_DID_SET_ROOT, _ => {
  didSetRootCallback && didSetRootCallback()
  shouldCallWillSetRootCallback = 0
})

EventEmitter.addListener(EVENT_WILL_SET_ROOT, _ => {
  if (shouldCallWillSetRootCallback === 0 && willSetRootCallback) {
    willSetRootCallback()
  }
})

EventEmitter.addListener(EVENT_SWITCH_TAB, event => {
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

export class Navigator {
  static RESULT_OK: -1 = NavigationModule.RESULT_OK
  static RESULT_CANCEL: 0 = NavigationModule.RESULT_CANCEL

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

    const flag = ++tag
    NavigationModule.setRoot(pureLayout, sticky, flag)

    return new Promise<void>(resolve => {
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

  visibility: Visibility = 'pending'

  setParams(params: { [index: string]: any }) {
    this.state.params = { ...this.state.params, ...params }
  }

  dispatch(action: string, params: Params = {}) {
    return Navigator.dispatch(this.sceneId, action, params)
  }

  result(requestCode: number, resultCode: number, data: any) {
    this.state.resultListeners.forEach(listener => {
      listener(requestCode, resultCode, data)
    })
  }

  private waitResult<T>(requestCode: number, successful: boolean): Promise<Result<T>> {
    if (!successful) {
      return Promise.resolve([0, {} as T])
    }
    return new Promise<Result<T>>(resolve => {
      const listener = (reqCode: number, resultCode: number, data: any) => {
        if (requestCode === reqCode) {
          resolve([resultCode, data])
          const index = this.state.resultListeners.indexOf(listener)
          if (index !== -1) {
            this.state.resultListeners.splice(index, 1)
          }
        }
      }
      this.state.resultListeners.push(listener)
    })
  }

  unmount() {
    this.state.unmountListeners.forEach(listener => {
      listener()
    })
    this.state.unmountListeners.length = 0
  }

  private waitUnmount(successful: boolean): Promise<void> {
    if (!successful) {
      return Promise.resolve()
    }
    return new Promise<void>(resolve => {
      this.state.unmountListeners.push(() => {
        resolve()
      })
    })
  }

  async push<T = any, P extends object = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
    animated = true,
  ) {
    const success = await this.dispatch('push', { moduleName, props, options, animated })
    return await this.waitResult<T>(0, success)
  }

  async pushLayout<T = any>(layout: Layout, animated = true) {
    const success = await this.dispatch('pushLayout', { layout, animated })
    return await this.waitResult<T>(0, success)
  }

  async pop(animated = true) {
    const success = await this.dispatch('pop', { animated })
    return await this.waitUnmount(success)
  }

  async popTo(sceneId: string, animated = true) {
    const success = await this.dispatch('popTo', { animated, targetId: sceneId })
    return await this.waitUnmount(success)
  }

  async popToRoot(animated = true) {
    const success = await this.dispatch('popToRoot', { animated })
    return await this.waitUnmount(success)
  }

  async redirectTo<P extends object = {}>(
    moduleName: string,
    props: P = {} as P,
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

  async present<T = any, P extends object = {}>(
    moduleName: string,
    requestCode = 0,
    props: P = {} as P,
    options: NavigationItem = {},
    animated = true,
  ) {
    const success = await this.dispatch('present', {
      moduleName,
      props,
      options,
      requestCode,
      animated,
    })
    return await this.waitResult<T>(requestCode, success)
  }

  async presentLayout<T = any>(layout: Layout, requestCode = 0, animated = true) {
    const success = await this.dispatch('presentLayout', { layout, requestCode, animated })
    return await this.waitResult<T>(requestCode, success)
  }

  async dismiss(animated = true) {
    const success = await this.dispatch('dismiss', { animated })
    return await this.waitUnmount(success)
  }

  async showModal<T = any, P extends object = {}>(
    moduleName: string,
    requestCode = 0,
    props: P = {} as P,
    options: NavigationItem = {},
  ) {
    const success = await this.dispatch('showModal', {
      moduleName,
      props,
      options,
      requestCode,
    })
    return await this.waitResult<T>(requestCode, success)
  }

  async showModalLayout<T = any>(layout: Layout, requestCode = 0) {
    const success = await this.dispatch('showModalLayout', { layout, requestCode })
    return await this.waitResult<T>(requestCode, success)
  }

  async hideModal() {
    const success = await this.dispatch('hideModal')
    return await this.waitUnmount(success)
  }

  setResult<T = any>(resultCode: number, data: T = {} as T): void {
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
