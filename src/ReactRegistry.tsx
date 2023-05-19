import { ComponentProvider } from 'react-native'
import type { RouteConfig } from './Route'

import Navigation, { HOC } from './Navigation'

/**
 * @deprecated use Navigation instead. import Navigation from 'hybrid-navigation'
 */
export class ReactRegistry {
  /**
   * @deprecated Use Navigation.startRegisterComponent() instead.
   * @param hoc
   */
  static startRegisterComponent(hoc?: HOC) {
    Navigation.startRegisterComponent(hoc)
  }

  /**
   * @deprecated Use Navigation.endRegisterComponent() instead.
   */
  static endRegisterComponent() {
    Navigation.endRegisterComponent()
  }

  /**
   *
   * @deprecated Use Navigation.registerComponent() instead.
   * @param appKey
   * @param getComponentFunc
   * @param routeConfig
   */
  static registerComponent(
    appKey: string,
    getComponentFunc: ComponentProvider,
    routeConfig?: RouteConfig,
  ) {
    Navigation.registerComponent(appKey, getComponentFunc, routeConfig)
  }
}
