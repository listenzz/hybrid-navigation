import { withNavigation } from './NavigationComponentWrap'
import navigation from './Navigation'
navigation.setNavigationComponentWrap(withNavigation)
const Navigation = navigation
export default Navigation
export { RESULT_OK, RESULT_CANCEL, RESULT_BLOCK } from './Navigation'
export { statusBarHeight, toolbarHeight, topBarHeight } from './GardenModule'
export { withNavigationItem } from './NavigationComponentWrap'
export type { NavigationProps } from './NavigationComponentWrap'

export * from './Navigator'
export * from './hooks'
export * from './router'
export * from './DeepLink'
export * from './Route'
export * from './Options'
