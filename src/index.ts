import { withNavigation } from './NavigationComponentWrap'
import Navigation from './Navigation'

Navigation.setNavigationComponentWrap(withNavigation)

export default Navigation
export { RESULT_OK, RESULT_CANCEL } from './Navigation'
export { statusBarHeight, toolbarHeight, topBarHeight } from './GardenModule'
export { withNavigationItem, NavigationProps } from './NavigationComponentWrap'

export * from './Navigator'
export * from './hooks'
export * from './router'
export * from './DeepLink'
export * from './Route'
export * from './Options'
