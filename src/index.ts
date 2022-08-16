import {
  withNavigation,
  withNavigationItem,
  NavigationProps,
  InjectedProps,
} from './NavigationComponentWrap'

import Navigation from './Navigation'

Navigation.setNavigationComponentWrap(withNavigation)

function statusBarHeight() {
  return Navigation.statusBarHeight()
}

function toolbarHeight() {
  return Navigation.toolbarHeight()
}

function topBarHeight() {
  return Navigation.topBarHeight()
}

export default Navigation

export { RESULT_OK, RESULT_CANCEL } from './Navigation'

export {
  withNavigationItem,
  NavigationProps,
  InjectedProps,
  statusBarHeight,
  toolbarHeight,
  topBarHeight,
}

export * from './Navigator'
export * from './Garden'
export * from './ReactRegistry'
export * from './hooks'
export * from './router'
export * from './DeepLink'
export * from './Route'
export * from './Options'
