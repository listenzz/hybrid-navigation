import { Platform } from 'react-native'
import Navigation from './Navigation'
import Event from './Event'
import GardenModule from './GardenModule'
import { withNavigation } from './NavigationComponentWrap'

Navigation.setNavigationComponentWrap(withNavigation)

const { STATUSBAR_HEIGHT, TOOLBAR_HEIGHT } = GardenModule.getConstants()
let _statusBarHeight = STATUSBAR_HEIGHT
if (Platform.OS === 'ios') {
  Event.listenStatusBarHeightChange(height => {
    _statusBarHeight = height
  })
}

function statusBarHeight() {
  return _statusBarHeight
}

function toolbarHeight() {
  return TOOLBAR_HEIGHT
}

function topBarHeight() {
  return statusBarHeight() + toolbarHeight()
}

export default Navigation
export { statusBarHeight, toolbarHeight, topBarHeight }
export { RESULT_OK, RESULT_CANCEL } from './Navigation'
export {
  withNavigation,
  withNavigationItem,
  NavigationProps,
  InjectedProps,
} from './NavigationComponentWrap'

export * from './Navigator'
export * from './Garden'
export * from './ReactRegistry'
export * from './hooks'
export * from './router'
export * from './DeepLink'
export * from './Route'
export * from './Options'
