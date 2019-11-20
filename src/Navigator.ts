import { Platform, EmitterSubscription } from 'react-native'
import {
  EventEmitter,
  NavigationModule,
  EVENT_WILL_SET_ROOT,
  EVENT_DID_SET_ROOT,
  EVENT_SWITCH_TAB,
  KEY_SCENE_ID,
  KEY_INDEX,
  KEY_MODULE_NAME,
  KEY_ON,
  EVENT_NAVIGATION,
  ON_COMPONENT_RESULT,
  KEY_REQUEST_CODE,
  KEY_RESULT_CODE,
  KEY_RESULT_DATA,
} from './NavigationModule'
import { bindBarButtonItemClickEvent } from './utils'
import store from './store'
import { NavigationItem } from './Garden'
import { Route, RouteGraph } from './router'

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

type Result<T> = [number, T]

interface NavigationState {
  params: { readonly [index: string]: any }
  subscriptions: EmitterSubscription[]
}

export type NavigationInterceptor = (
  action: string,
  from?: string,
  to?: string,
  extras?: Extras,
) => boolean

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

function result<T>(navigator: Navigator, requestCode: number) {
  return new Promise<Result<T>>(resolve => {
    const subscription = EventEmitter.addListener(
      EVENT_NAVIGATION,
      (data: { [index: string]: any }) => {
        if (
          navigator.sceneId === data[KEY_SCENE_ID] &&
          data[KEY_ON] === ON_COMPONENT_RESULT &&
          data[KEY_REQUEST_CODE] === requestCode
        ) {
          navigator.removeSubscription(subscription)
          resolve([data[KEY_RESULT_CODE], data[KEY_RESULT_DATA]])
        }
      },
    )
    navigator.addSubscription(subscription)
  })
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
    await Navigator.foreground()
    return await NavigationModule.currentRoute()
  }

  static async routeGraph(): Promise<RouteGraph[]> {
    await Navigator.foreground()
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

  static async dispatch(sceneId: string, action: string, params: Params = {}): Promise<void> {
    await Navigator.foreground()
    const navigator = Navigator.get(sceneId)
    if (
      !intercept ||
      !intercept(action, navigator.moduleName, params.moduleName, {
        sceneId,
        index: params.index,
      })
    ) {
      NavigationModule.dispatch(sceneId, action, params)
    }
  }

  static setInterceptor(interceptor: NavigationInterceptor) {
    intercept = interceptor
  }

  static reload() {
    NavigationModule.reload()
  }

  static delay(ms: number): Promise<{}> {
    return NavigationModule.delay(ms)
  }

  static foreground(): Promise<void> {
    if (Platform.OS === 'android') {
      return NavigationModule.foreground()
    } else {
      return Promise.resolve()
    }
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
    this.replace = this.replace.bind(this)
    this.replaceToRoot = this.replaceToRoot.bind(this)
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
    subscriptions: [],
  }

  addSubscription(subscription: EmitterSubscription) {
    this.state.subscriptions.push(subscription)
  }

  removeSubscription(subscription: EmitterSubscription) {
    const index = this.state.subscriptions.indexOf(subscription)
    if (index !== -1) {
      subscription.remove()
      this.state.subscriptions.splice(index, 1)
    }
  }

  clearSubscriptions() {
    this.state.subscriptions.splice(0).forEach(item => {
      item.remove()
    })
  }

  setParams(params: { [index: string]: any }) {
    this.state.params = { ...this.state.params, ...params }
  }

  dispatch(action: string, params: Params = {}) {
    Navigator.dispatch(this.sceneId, action, params)
  }

  push<T = any, P extends object = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
    animated = true,
  ) {
    this.dispatch('push', { moduleName, props, options, animated })
    return result<T>(this, 0)
  }

  pushLayout<T = any>(layout: Layout, animated = true) {
    this.dispatch('pushLayout', { layout, animated })
    return result<T>(this, 0)
  }

  pop(animated = true) {
    this.dispatch('pop', { animated })
  }

  popTo(sceneId: string, animated = true) {
    this.dispatch('popTo', { animated, targetId: sceneId })
  }

  popToRoot(animated = true) {
    this.dispatch('popToRoot', { animated })
  }

  replace<P extends object = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) {
    this.dispatch('replace', { moduleName, props, options, animated: true })
  }

  replaceToRoot<P extends object = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) {
    this.dispatch('replaceToRoot', { moduleName, props, options, animated: true })
  }

  isStackRoot(): Promise<boolean> {
    return NavigationModule.isNavigationRoot(this.sceneId)
  }

  present<T = any, P extends object = {}>(
    moduleName: string,
    requestCode = 0,
    props: P = {} as P,
    options: NavigationItem = {},
    animated = true,
  ) {
    this.dispatch('present', {
      moduleName,
      props,
      options,
      requestCode,
      animated,
    })
    return result<T>(this, requestCode)
  }

  presentLayout<T = any>(layout: Layout, requestCode = 0, animated = true) {
    this.dispatch('presentLayout', { layout, requestCode, animated })
    return result<T>(this, requestCode)
  }

  dismiss(animated = true) {
    this.dispatch('dismiss', { animated })
  }

  showModal<T = any, P extends object = {}>(
    moduleName: string,
    requestCode = 0,
    props: P = {} as P,
    options: NavigationItem = {},
  ) {
    this.dispatch('showModal', {
      moduleName,
      props,
      options,
      requestCode,
    })
    return result<T>(this, requestCode)
  }

  showModalLayout<T = any>(layout: Layout, requestCode = 0) {
    this.dispatch('showModalLayout', { layout, requestCode })
    return result<T>(this, requestCode)
  }

  hideModal() {
    this.dispatch('hideModal')
  }

  setResult<T = any>(resultCode: number, data: T = {} as T): void {
    NavigationModule.setResult(this.sceneId, resultCode, data)
  }

  switchTab(index: number, popToRoot: boolean = false) {
    this.dispatch('switchTab', { index, popToRoot })
  }

  toggleMenu() {
    this.dispatch('toggleMenu')
  }

  openMenu() {
    this.dispatch('openMenu')
  }

  closeMenu() {
    this.dispatch('closeMenu')
  }

  signalFirstRenderComplete(): void {
    NavigationModule.signalFirstRenderComplete(this.sceneId)
  }
}
