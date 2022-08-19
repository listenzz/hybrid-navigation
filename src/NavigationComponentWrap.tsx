import React, { useEffect } from 'react'
import type { Garden } from './Garden'
import type { NavigationItem } from './Options'
import { Navigator, NavigationContext } from './Navigator'

export interface NavigationProps {
  navigator: Navigator
  garden: Garden
  sceneId: string
}

/**
 * @deprecated Use NavigationProps instead.
 */
export type InjectedProps = NavigationProps

interface NativeProps {
  sceneId: string
}

function getDisplayName(WrappedComponent: React.ComponentType<any>) {
  return WrappedComponent.displayName || WrappedComponent.name || 'Component'
}

export function withNavigation(moduleName: string) {
  return function (WrappedComponent: React.ComponentType<any>) {
    const FC = React.forwardRef((props: NativeProps, ref: React.Ref<React.ComponentType<any>>) => {
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
