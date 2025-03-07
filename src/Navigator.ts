import { createContext } from 'react'

import store from './store'
import type { Visibility, Layout, BuildInLayout } from './Route'
import type { NavigationItem } from './Options'
import Navigation, { ResultType, RESULT_CANCEL } from './Navigation'

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

  static unmount = (sceneId: string) => {
    store.removeNavigator(sceneId)
    Navigation.unmount(sceneId)
  }

  static async find(moduleName: string) {
    const sceneId = await Navigation.findSceneIdByModuleName(moduleName)
    if (sceneId) {
      return Navigator.of(sceneId)
    }
  }

  static async current(): Promise<Navigator> {
    const route = await Navigation.currentRoute()
    return Navigator.of(route.sceneId)
  }

  constructor(public sceneId: string, public moduleName?: string) {}

  visibility: Visibility = 'pending'

  readonly state: NavigationState = {
    params: {},
  }

  setParams = (params: { [index: string]: any }) => {
    this.state.params = { ...this.state.params, ...params }
  }

  push = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const success = await Navigation.dispatch(this.sceneId, 'push', {
      moduleName,
      from: this.moduleName,
      to: moduleName,
      props,
      options,
    })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return Navigation.result<T>(this.sceneId, 0)
  }

  pushLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const success = await Navigation.dispatch(this.sceneId, 'pushLayout', {
      from: this.moduleName,
      layout,
    })
    if (!success) {
      return [RESULT_CANCEL, null] as [number, T]
    }
    return Navigation.result<T>(this.sceneId, 0)
  }

  pop = () => Navigation.dispatch(this.sceneId, 'pop', { from: this.moduleName })

  popTo = (moduleName: string, inclusive: boolean = false) =>
    Navigation.dispatch(this.sceneId, 'popTo', { moduleName, inclusive, from: this.moduleName })

  popToRoot = () => Navigation.dispatch(this.sceneId, 'popToRoot', { from: this.moduleName })

  redirectTo = <P extends PropsType>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) =>
    Navigation.dispatch(this.sceneId, 'redirectTo', {
      moduleName,
      from: this.moduleName,
      to: moduleName,
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
      from: this.moduleName,
      to: moduleName,
      props,
      options,
      requestCode,
    })
    if (!success) {
      console.warn(
        `present from:${this.moduleName} to:${moduleName} failed. Maybe the screen (${this.moduleName}) already shows or present another screen.`,
      )
      return [RESULT_CANCEL, null] as [number, T]
    }
    return Navigation.result<T>(this.sceneId, requestCode)
  }

  presentLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'presentLayout', {
      layout,
      from: this.moduleName,
      requestCode,
    })
    if (!success) {
      console.warn(
        `presentLayout from:${this.moduleName} failed. Maybe the screen (${this.moduleName}) already shows or present another screen.`,
      )
      return [RESULT_CANCEL, null] as [number, T]
    }
    return Navigation.result<T>(this.sceneId, requestCode)
  }

  dismiss = () => Navigation.dispatch(this.sceneId, 'dismiss', { from: this.moduleName })

  showModal = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'showModal', {
      moduleName,
      from: this.moduleName,
      to: moduleName,
      props,
      options,
      requestCode,
    })
    if (!success) {
      console.warn(
        `showModal from:${this.moduleName} to:${moduleName} failed. Maybe the screen (${this.moduleName}) already shows or present another screen.`,
      )
      return [RESULT_CANCEL, null] as [number, T]
    }
    return Navigation.result<T>(this.sceneId, requestCode)
  }

  showModalLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const requestCode = --tagGenerator
    const success = await Navigation.dispatch(this.sceneId, 'showModalLayout', {
      from: this.moduleName,
      layout,
      requestCode,
    })
    if (!success) {
      console.warn(
        `showModal from:${this.moduleName} failed. Maybe the screen (${this.moduleName}) already shows or present another screen.`,
      )
      return [RESULT_CANCEL, null] as [number, T]
    }
    return Navigation.result<T>(this.sceneId, requestCode)
  }

  hideModal = () => Navigation.dispatch(this.sceneId, 'hideModal', { from: this.moduleName })

  setResult = <T extends ResultType>(resultCode: number, data: T = null as any): void =>
    Navigation.setResult(this.sceneId, resultCode, data)

  switchTab = async (index: number, popToRoot: boolean = false) => {
    const from = await Navigation.currentTab(this.sceneId)
    return Navigation.dispatch(this.sceneId, 'switchTab', { from, to: index, popToRoot })
  }

  toggleMenu = () => Navigation.dispatch(this.sceneId, 'toggleMenu', { from: this.moduleName })

  openMenu = () => Navigation.dispatch(this.sceneId, 'openMenu', { from: this.moduleName })

  closeMenu = () => Navigation.dispatch(this.sceneId, 'closeMenu', { from: this.moduleName })

  isStackRoot = () => Navigation.isStackRoot(this.sceneId)
}
