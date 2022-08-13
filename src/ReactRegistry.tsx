import { AppRegistry, ComponentProvider } from 'react-native'
import React, { useEffect } from 'react'
import { Navigator, NavigationContext } from './Navigator'
import { Garden } from './Garden'
import { router } from './router'
import NavigationModule from './NavigationModule'
import Event from './Event'
import { NavigationItem } from './Options'
import { RouteConfig } from './Route'

export interface InjectedProps {
  navigator: Navigator
  garden: Garden
  sceneId: string
}

interface Props {
  sceneId: string
}

function getDisplayName(WrappedComponent: React.ComponentType<any>) {
  return WrappedComponent.displayName || WrappedComponent.name || 'Component'
}

function withNavigation(moduleName: string) {
  return function (WrappedComponent: React.ComponentType<any>) {
    const FC = React.forwardRef((props: Props, ref: React.Ref<React.ComponentType<any>>) => {
      const { sceneId } = props

      const navigator = Navigator.of(sceneId)
      if (navigator.moduleName === undefined) {
        navigator.moduleName = moduleName
      }

      const garden = navigator.garden

      useEffect(() => {
        navigator.signalFirstRenderComplete()
        return () => {
          navigator.unmount()
        }
      }, [navigator])

      const injected = {
        garden,
        navigator,
      }

      return (
        <NavigationContext.Provider value={navigator}>
          <WrappedComponent ref={ref} {...props} {...injected} />
        </NavigationContext.Provider>
      )
    })

    FC.displayName = `withNavigation(${getDisplayName(WrappedComponent)})`
    return FC
  }
}

export type HOC = (WrappedComponent: React.ComponentType<any>) => React.ComponentType<any>
let wrap: HOC | undefined

export class ReactRegistry {
  static registerEnded: boolean
  static startRegisterComponent(hoc?: HOC) {
    wrap = hoc
    ReactRegistry.registerEnded = false
    NavigationModule.startRegisterReactComponent()
  }

  static endRegisterComponent() {
    if (ReactRegistry.registerEnded) {
      console.warn(`Please don't call ReactRegistry#endRegisterComponent multiple times.`)
      return
    }
    ReactRegistry.registerEnded = true
    NavigationModule.endRegisterReactComponent()
  }

  static registerComponent(
    appKey: string,
    getComponentFunc: ComponentProvider,
    routeConfig?: RouteConfig,
  ) {
    if (routeConfig) {
      router.registerRoute(appKey, routeConfig)
    }

    let WrappedComponent = getComponentFunc()
    if (wrap) {
      WrappedComponent = wrap(WrappedComponent)
    }

    // build static options
    let options: object =
      Event.bindBarButtonClickEvent('permanent', (WrappedComponent as any).navigationItem) || {}
    NavigationModule.registerReactComponent(appKey, options)

    let RootComponent = withNavigation(appKey)(WrappedComponent)
    AppRegistry.registerComponent(appKey, () => RootComponent)
  }
}

export function withNavigationItem(item: NavigationItem) {
  return function (WrappedComponent: React.ComponentType<any>): React.ComponentType<any> {
    let navigationItem = (WrappedComponent as any).navigationItem
    if (navigationItem) {
      ;(WrappedComponent as any).navigationItem = { ...navigationItem, ...item }
    } else {
      ;(WrappedComponent as any).navigationItem = item
    }
    return WrappedComponent
  }
}
