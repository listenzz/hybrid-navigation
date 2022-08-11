import { NativeModules, NativeEventEmitter } from 'react-native'

const NavigationModule = NativeModules.NavigationModule
const HBDEventEmitter = NativeModules.HBDEventEmitter

const EventEmitter: NativeEventEmitter = new NativeEventEmitter(HBDEventEmitter)
export const EVENT_SWITCH_TAB: string = HBDEventEmitter.EVENT_SWITCH_TAB
export const EVENT_NAVIGATION: string = HBDEventEmitter.EVENT_NAVIGATION
export const EVENT_WILL_SET_ROOT: string = HBDEventEmitter.EVENT_WILL_SET_ROOT
export const EVENT_DID_SET_ROOT: string = HBDEventEmitter.EVENT_DID_SET_ROOT

export const ON_COMPONENT_RESULT: string = HBDEventEmitter.ON_COMPONENT_RESULT
export const ON_BAR_BUTTON_ITEM_CLICK: string = HBDEventEmitter.ON_BAR_BUTTON_ITEM_CLICK
export const ON_COMPONENT_APPEAR: string = HBDEventEmitter.ON_COMPONENT_APPEAR
export const ON_COMPONENT_DISAPPEAR: string = HBDEventEmitter.ON_COMPONENT_DISAPPEAR

export const KEY_ON: string = HBDEventEmitter.KEY_ON
export const KEY_REQUEST_CODE: string = HBDEventEmitter.KEY_REQUEST_CODE
export const KEY_RESULT_CODE: string = HBDEventEmitter.KEY_RESULT_CODE
export const KEY_RESULT_DATA: string = HBDEventEmitter.KEY_RESULT_DATA
export const KEY_SCENE_ID: string = HBDEventEmitter.KEY_SCENE_ID
export const KEY_MODULE_NAME: string = HBDEventEmitter.KEY_MODULE_NAME
export const KEY_INDEX: string = HBDEventEmitter.KEY_INDEX
export const KEY_ACTION: string = HBDEventEmitter.KEY_ACTION

export const RESULT_OK: number = NavigationModule.RESULT_OK
export const RESULT_CANCEL: number = NavigationModule.RESULT_CANCEL

export { EventEmitter, NavigationModule }
