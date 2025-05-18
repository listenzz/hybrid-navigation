import NavigationModule from '../NavigationModule';
import { NavigationItem } from '../Options';
import { BuildInLayout, Layout } from '../Route';

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
  props?: object
}

export type NavigationInterceptor = (
  action: string,
  params: InterceptParams,
) => boolean | Promise<boolean>

export default class DispatchCommandHandler {
  private interceptor: NavigationInterceptor = () => false;

  async dispatch(sceneId: string, action: string, params: DispatchParams): Promise<boolean> {
    const { from, to, props } = params;
    const intercepted = await this.intercept(action, {
      sceneId,
      from,
      to,
      props,
    });

    if (intercepted) {
      return false;
    }
    return NavigationModule.dispatch(sceneId, action, params);
  }

  private intercept(action: string, params: InterceptParams) {
    if (!this.interceptor) {
      return Promise.resolve(false);
    }

    const result = this.interceptor(action, params);
    if (result instanceof Promise) {
      return result;
    }
    return Promise.resolve(result);
  }

  setInterceptor(interceptor: NavigationInterceptor) {
    this.interceptor = interceptor;
  }
}
