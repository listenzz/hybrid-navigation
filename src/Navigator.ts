import { createContext } from 'react'

import NavigationModule from './NavigationModule'
import Event from './Event'
import store from './store'
import { Visibility, Layout, BuildInLayout, Route, RouteGraph } from './Route'
import { NavigationItem } from './Options'
import { Garden } from './Garden'

const { RESULT_CANCEL } = NavigationModule.getConstants()

export const NavigationContext = createContext<any>(null)

interface NavigationState {
  params: { readonly [index: string]: any }
}

interface IndexType {
  [index: string]: any
}
interface PropsType {
  [index: string]: any
}

interface DispatchParams {
  animated?: boolean
  moduleName?: string
  layout?: BuildInLayout | Layout
  popToRoot?: boolean
  requestCode?: number
  props?: object
  options?: NavigationItem
  [index: string]: any
}

interface InterceptParams {
  sceneId: string
  from?: number | string
  to?: number | string
}
export interface NavigationInterceptor {
  (action: string, params: InterceptParams): boolean | Promise<boolean>
}

let interceptor: NavigationInterceptor
let shouldCallWillSetRootCallback = 0
let willSetRootCallback: () => void
let didSetRootCallback: () => void
let tagGenerator = 0

Event.listenSetRoot(
  () => {
    if (shouldCallWillSetRootCallback === 0 && willSetRootCallback) {
      willSetRootCallback()
    }
  },
  () => {
    didSetRootCallback && didSetRootCallback()
    shouldCallWillSetRootCallback = 0
  },
)

Event.listenSwitchTab((sceneId: string, from: number, to: number) => {
  Navigator.dispatch(sceneId, 'switchTab', { from, to })
})

type ResultType = IndexType | null
interface ResultListener<T extends ResultType> {
  (resultCode: number, data: T): void
  cancel: () => void
  sceneId: string
}

const globalResultListeners = new Map<number, ResultListener<any>>()

Event.listenComponentResult(
  (sceneId: string, requestCode: number, resultCode: number, data: any) => {
    if (requestCode < 0) {
      const listener = globalResultListeners.get(requestCode)
      if (listener) {
        globalResultListeners.delete(requestCode)
        listener(resultCode, data)
      }
    } else {
      const navigator = Navigator.of(sceneId)
      navigator.result(resultCode, data)
    }
  },
)

Event.listenComponentVisibility(
  (sceneId: string) => {
    const navigator = store.getNavigator(sceneId)
    if (navigator) {
      navigator.visibility = 'visible'
    }
  },
  (sceneId: string) => {
    const navigator = store.getNavigator(sceneId)
    if (navigator) {
      navigator.visibility = 'invisible'
    }
  },
)

Event.setBarButtonClickHandlerFactory(() => {
  return (sceneId, value) => {
    const navigator = Navigator.of(sceneId)
    value(navigator)
  }
})

export class Navigator {
  static of(sceneId: string) {
    let navigator = store.getNavigator(sceneId)
    if (!navigator) {
      navigator = new Navigator(sceneId)
      store.addNavigator(sceneId, navigator)
    }
    return navigator
  }

  static async find(moduleName: string) {
    const sceneId = await NavigationModule.findSceneIdByModuleName(moduleName)
    if (sceneId) {
      return Navigator.of(sceneId)
    }
  }

  static async current(): Promise<Navigator> {
    const route = await Navigator.currentRoute()
    return Navigator.of(route.sceneId)
  }

  static currentRoute(): Promise<Route> {
    return NavigationModule.currentRoute()
  }

  static routeGraph(): Promise<RouteGraph[]> {
    return NavigationModule.routeGraph()
  }

  static setRoot(layout: BuildInLayout | Layout, sticky = false) {
    if (willSetRootCallback) {
      shouldCallWillSetRootCallback++
      willSetRootCallback()
    }

    const flag = --tagGenerator
    NavigationModule.setRoot(layout, sticky, flag)

    return new Promise<void>(resolve => {
      const subscription = Event.listenSetRoot(
        () => {},
        (tag: number) => {
          if (tag === flag) {
            subscription.remove()
            resolve()
          }
        },
      )
    })
  }

  static setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    willSetRootCallback = willSetRoot
    didSetRootCallback = didSetRoot
  }

  static async dispatch(
    sceneId: string,
    action: string,
    params: DispatchParams = {},
  ): Promise<boolean> {
    let intercepted = false
    const { from, to } = params
    if (interceptor) {
      const result = interceptor(action, {
        sceneId,
        from,
        to,
      })
      if (result instanceof Promise) {
        intercepted = await result
      } else {
        intercepted = result
      }
    }

    if (!intercepted) {
      return NavigationModule.dispatch(sceneId, action, params)
    }

    return false
  }

  static setInterceptor(interceptFn: NavigationInterceptor) {
    interceptor = interceptFn
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

  dispatch = (action: string, params: DispatchParams = {}) => {
    return Navigator.dispatch(this.sceneId, action, {
      from: this.moduleName,
      to: params.moduleName,
      ...params,
    })
  }

  result = (resultCode: number, data: ResultType) => {
    if (this.resultListener) {
      this.resultListener(resultCode, data)
      this.resultListener = null
    }
  }

  unmount = () => {
    Event.removeBarButtonClickEvent(this.sceneId)
    store.removeNavigator(this.sceneId)

    const codes: number[] = []
    for (const [requestCode, listener] of globalResultListeners) {
      if (listener.sceneId === this.sceneId) {
        codes.push(requestCode)
        listener.cancel()
      }
    }
    codes.forEach(code => globalResultListeners.delete(code))

    if (this.resultListener) {
      this.resultListener.cancel()
      this.resultListener = null
    }
  }

  private resultListener: ResultListener<any> | null = null

  private waitResult<T extends ResultType>(requestCode: number): Promise<[number, T]> {
    if (this.resultListener) {
      this.resultListener.cancel()
      this.resultListener = null
    }

    return new Promise<[number, T]>(resolve => {
      const listener = (resultCode: number, data: T) => {
        resolve([resultCode, data])
      }

      listener.cancel = () => {
        resolve([RESULT_CANCEL, null] as [number, T])
      }

      listener.sceneId = this.sceneId

      if (requestCode < 0) {
        globalResultListeners.set(requestCode, listener)
      } else {
        this.resultListener = listener
      }
    })
  }

  push = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const success = await this.dispatch('push', { moduleName, props, options })
    if (!success) {
      return [RESULT_CANCEL] as unknown as [number, T]
    }
    return await this.waitResult<T>(0)
  }

  pushLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const success = await this.dispatch('pushLayout', { layout })
    if (!success) {
      return [RESULT_CANCEL] as unknown as [number, T]
    }
    return await this.waitResult<T>(0)
  }

  pop = () => this.dispatch('pop')

  popTo = (moduleName: string, inclusive: boolean = false) =>
    this.dispatch('popTo', { moduleName, inclusive })

  popToRoot = () => this.dispatch('popToRoot')

  redirectTo = <P extends PropsType>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) =>
    this.dispatch('redirectTo', {
      moduleName,
      props,
      options,
    })

  isStackRoot = () => NavigationModule.isStackRoot(this.sceneId)

  present = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const requestCode = --tagGenerator
    const success = await this.dispatch('present', {
      moduleName,
      props,
      options,
      requestCode,
    })
    if (!success) {
      return [RESULT_CANCEL] as unknown as [number, T]
    }
    return await this.waitResult<T>(requestCode)
  }

  presentLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const requestCode = --tagGenerator
    const success = await this.dispatch('presentLayout', { layout, requestCode })
    if (!success) {
      return [RESULT_CANCEL] as unknown as [number, T]
    }
    return await this.waitResult<T>(requestCode)
  }

  dismiss = () => this.dispatch('dismiss')

  showModal = async <T extends ResultType, P extends PropsType = {}>(
    moduleName: string,
    props: P = {} as P,
    options: NavigationItem = {},
  ) => {
    const requestCode = --tagGenerator
    const success = await this.dispatch('showModal', {
      moduleName,
      props,
      options,
      requestCode,
    })
    if (!success) {
      return [RESULT_CANCEL] as unknown as [number, T]
    }
    return await this.waitResult<T>(requestCode)
  }

  showModalLayout = async <T extends ResultType>(layout: BuildInLayout | Layout) => {
    const requestCode = --tagGenerator
    const success = await this.dispatch('showModalLayout', { layout, requestCode })
    if (!success) {
      return [RESULT_CANCEL] as unknown as [number, T]
    }
    return await this.waitResult<T>(requestCode)
  }

  hideModal = () => this.dispatch('hideModal')

  setResult = <T extends ResultType>(resultCode: number, data: T = null as any): void =>
    NavigationModule.setResult(this.sceneId, resultCode, data)

  switchTab = async (index: number, popToRoot: boolean = false) => {
    const from = await NavigationModule.currentTab(this.sceneId)
    return this.dispatch('switchTab', { from, to: index, popToRoot })
  }

  toggleMenu = () => this.dispatch('toggleMenu')

  openMenu = () => this.dispatch('openMenu')

  closeMenu = () => this.dispatch('closeMenu')

  signalFirstRenderComplete = () => NavigationModule.signalFirstRenderComplete(this.sceneId)
}
