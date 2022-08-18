import NavigationModule from '../NavigationModule'
import { NavigationItem } from '../Options'
import { BuildInLayout, Layout } from '../Route'

export interface DispatchParams {
  animated?: boolean
  moduleName?: string
  from?: string | number
  to?: string | number
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

export type NavigationInterceptor = (
  action: string,
  params: InterceptParams,
) => boolean | Promise<boolean>

export default class DispatchCommandHandler {
  private interceptor: NavigationInterceptor = () => false

  async dispatch(sceneId: string, action: string, params: DispatchParams): Promise<boolean> {
    let intercepted = false
    const { from, to } = params
    if (this.interceptor) {
      const result = this.interceptor(action, {
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

  setInterceptor(interceptor: NavigationInterceptor) {
    this.interceptor = interceptor
  }
}
