import { createContext } from 'react'

import store from './store'
import type { Visibility, Layout, BuildInLayout, Route, RouteGraph } from './Route'
import type { NavigationItem } from './Options'
import { Garden } from './Garden'
import Navigation, {
  NavigationInterceptor,
  DispatchParams,
  ResultType,
  RESULT_CANCEL,
} from './Navigation'

export const NavigationContext = createContext<any>(null)

interface NavigationState {
  params: { readonly [index: string]: any }
}

interface PropsType {
  [index: string]: any
}

let tagGenerator = 0

Navigation.addGlobalVisibilityEventListener((sceneId: string, visibility: Visibility) => {
  const navigator = store.getNavigator(sceneId)
  if (navigator) {
    navigator.visibility = visibility
  }
})

Navigation.setBarButtonClickEventListener((sceneId, value) => {
  const navigator = Navigator.of(sceneId)
  value(navigator)
})

export interface Navigator {}

export class Navigator implements Navigator {
  static of(sceneId: string) {
    let navigator = store.getNavigator(sceneId)
    if (!navigator) {
      navigator = new Navigator(sceneId)
      store.addNavigator(sceneId, navigator)
    }
    return navigator
  }

  static async find(moduleName: string) {
    const sceneId = await Navigation.findSceneIdByModuleName(moduleName)
    if (sceneId) {
      return Navigator.of(sceneId)
    }
  }

  static async current(): Promise<Navigator> {
    const route = await Navigator.currentRoute()
    return Navigator.of(route.sceneId)
  }

  static currentRoute(): Promise<Route> {
    return Navigation.currentRoute()
  }

  static routeGraph(): Promise<RouteGraph[]> {
    return Navigation.routeGraph()
  }

  static setRoot(layout: BuildInLayout | Layout, sticky = false) {
    Navigation.setRoot(layout, sticky)
  }

  static setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    Navigation.setRootLayoutUpdateListener(willSetRoot, didSetRoot)
  }

  static async dispatch(
    sceneId: string,
    action: string,
    params: DispatchParams = {},
  ): Promise<boolean> {
    return Navigation.dispatch(sceneId, action, params)
  }

  static setInterceptor(interceptFn: NavigationInterceptor) {
    Navigation.setInterceptor(interceptFn)
  }

  constructor(public sceneId: string, public moduleName?: string) {}

  private _garden?: Garden

  get garden() {
    if (!this._garden) {
      this._garden = new Garden(this.sceneId)
    }
    return this._garden
  }

  visibility: Visibility = 'pending'

  readonly state: NavigationState = {
    params: {},
  }

  setParams = (params: { [index: string]: any }) => {
    this.state.params = { ...this.state.params, ...params }
  }

  unmount = () => {
    store.removeNavigator(this.sceneId)
    Navigation.unmount(this.sceneId)
  }

  push = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const success = await Navigation.dispatch(this.sceneId, 'push', { moduleName, props, options })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return await Navigation.result<T>(this.sceneId, 0)
  }

  pushLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const success = await Navigation.dispatch(this.sceneId, 'pushLayout', { layout })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return await Navigation.result<T>(this.sceneId, 0)
  }

  pop = () => Navigation.dispatch(this.sceneId, 'pop')

  popTo = (moduleName: string, inclusive: boolean = false) =>
    Navigation.dispatch(this.sceneId, 'popTo', { moduleName, inclusive })

  popToRoot = () => Navigation.dispatch(this.sceneId, 'popToRoot')

  redirectTo = <P extends PropsType>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) =>
    Navigation.dispatch(this.sceneId, 'redirectTo', {
      moduleName,
      props,
      options,
    })

  present = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'present', {
      moduleName,
      props,
      options,
      requestCode,
    })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return await Navigation.result<T>(this.sceneId, requestCode)
  }

  presentLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'presentLayout', {
      layout,
      requestCode,
    })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return await Navigation.result<T>(this.sceneId, requestCode)
  }

  dismiss = () => Navigation.dispatch(this.sceneId, 'dismiss')

  showModal = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'showModal', {
      moduleName,
      props,
      options,
      requestCode,
    })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return await Navigation.result<T>(this.sceneId, requestCode)
  }

  showModalLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'showModalLayout', {
      layout,
      requestCode,
    })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return await Navigation.result<T>(this.sceneId, requestCode)
  }

  hideModal = () => Navigation.dispatch(this.sceneId, 'hideModal')

  setResult = <T extends ResultType>(resultCode: number, data: T = null as any): void =>
    Navigation.setResult(this.sceneId, resultCode, data)

  switchTab = async (index: number, popToRoot: boolean = false) => {
    const from = await Navigation.currentTab(this.sceneId)
    return Navigation.dispatch(this.sceneId, 'switchTab', { from, to: index, popToRoot })
  }

  toggleMenu = () => Navigation.dispatch(this.sceneId, 'toggleMenu')

  openMenu = () => Navigation.dispatch(this.sceneId, 'openMenu')

  closeMenu = () => Navigation.dispatch(this.sceneId, 'closeMenu')

  isStackRoot = () => Navigation.isStackRoot(this.sceneId)

  signalFirstRenderComplete = () => Navigation.signalFirstRenderComplete(this.sceneId)
}
