import { NativeModules, NativeEventEmitter, NativeModule, EventSubscription } from 'react-native'
import GardenModule from './GardenModule'

function listenStatusBarHeightChanged(listener: (statusBarHeight: number) => void) {
  const GardenEventReceiver = new NativeEventEmitter(GardenModule)
  const { EVENT_STATUSBAR_FRAME_CHANGE } = GardenModule.getConstants()
  return GardenEventReceiver.addListener(EVENT_STATUSBAR_FRAME_CHANGE, ({ statusBarHeight }) => {
    listener(statusBarHeight)
  })
}

interface HBDEventEmitter extends NativeModule {
  getConstants: () => {
    EVENT_NAVIGATION: string
    EVENT_SWITCH_TAB: string
    EVENT_DID_SET_ROOT: string
    EVENT_WILL_SET_ROOT: string
    ON_COMPONENT_RESULT: string
    ON_BAR_BUTTON_ITEM_CLICK: string
    ON_COMPONENT_APPEAR: string
    ON_COMPONENT_DISAPPEAR: string
    KEY_REQUEST_CODE: string
    KEY_RESULT_CODE: string
    KEY_RESULT_DATA: string
    KEY_SCENE_ID: string
    KEY_MODULE_NAME: string
    KEY_INDEX: string
    KEY_ACTION: string
    KEY_ON: string
  }
}

const HBDEventEmitter: HBDEventEmitter = NativeModules.HBDEventEmitter
const HBDEventReceiver = new NativeEventEmitter(HBDEventEmitter)

function listenComponentResult(
  listener: (sceneId: string, requestCode: number, resultCode: number, resultData: object) => void,
) {
  const {
    EVENT_NAVIGATION,
    KEY_ON,
    ON_COMPONENT_RESULT,
    KEY_REQUEST_CODE,
    KEY_RESULT_CODE,
    KEY_RESULT_DATA,
    KEY_SCENE_ID,
  } = HBDEventEmitter.getConstants()

  return HBDEventReceiver.addListener(EVENT_NAVIGATION, data => {
    if (data[KEY_ON] === ON_COMPONENT_RESULT) {
      const requestCode = data[KEY_REQUEST_CODE]
      const resultCode = data[KEY_RESULT_CODE]
      const resultData = data[KEY_RESULT_DATA]
      const sceneId = data[KEY_SCENE_ID]

      listener(sceneId, requestCode, resultCode, resultData)
    }
  })
}

function listenComponentVisibility(
  componentDidAppear: (sceneId: string) => void,
  componentDidDisappear: (sceneId: string) => void,
) {
  const { EVENT_NAVIGATION, KEY_ON, ON_COMPONENT_APPEAR, ON_COMPONENT_DISAPPEAR, KEY_SCENE_ID } =
    HBDEventEmitter.getConstants()

  return HBDEventReceiver.addListener(EVENT_NAVIGATION, data => {
    if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
      componentDidAppear(data[KEY_SCENE_ID])
    } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
      componentDidDisappear(data[KEY_SCENE_ID])
    }
  })
}

function listenBarButtonItemClick(listener: (sceneId: string, action: string) => void) {
  const { EVENT_NAVIGATION, KEY_ON, ON_BAR_BUTTON_ITEM_CLICK, KEY_ACTION, KEY_SCENE_ID } =
    HBDEventEmitter.getConstants()

  return HBDEventReceiver.addListener(
    EVENT_NAVIGATION,
    data => {
      if (data[KEY_ON] === ON_BAR_BUTTON_ITEM_CLICK) {
        listener(data[KEY_SCENE_ID], data[KEY_ACTION])
      }
    },
    {},
  )
}

function listenSwitchTab(listener: (sceneId: string, from: number, to: number) => void) {
  const { EVENT_SWITCH_TAB, KEY_INDEX, KEY_SCENE_ID } = HBDEventEmitter.getConstants()
  return HBDEventReceiver.addListener(EVENT_SWITCH_TAB, event => {
    const index = event[KEY_INDEX]
    const [from, to] = index.split('-')
    listener(event[KEY_SCENE_ID], parseInt(from, 10), parseInt(to, 10))
  })
}

function listenSetRoot(willSetRoot: () => void, didSetRoot: (tag: number) => void) {
  const { EVENT_WILL_SET_ROOT, EVENT_DID_SET_ROOT } = HBDEventEmitter.getConstants()

  const subscriptions: EventSubscription[] = []

  subscriptions.push(
    HBDEventReceiver.addListener(EVENT_WILL_SET_ROOT, _ => {
      willSetRoot()
    }),
  )

  subscriptions.push(
    HBDEventReceiver.addListener(EVENT_DID_SET_ROOT, (event: { tag: number }) => {
      didSetRoot(event.tag)
    }),
  )

  return {
    remove: () => {
      subscriptions.forEach(subscription => subscription.remove())
    },
  }
}

const actions: Record<string, Function> = {}
const keyPairs: Record<string, string[]> = {}

let actionIdGenerator = 0
let barButtonClickHandlerFactory = () => {
  return (sceneId: string, value: Function) => {
    console.warn(`barButtonClickHandlerFactory 没有正确绑定`, sceneId, value)
  }
}

function setBarButtonClickHandlerFactory(generator: typeof barButtonClickHandlerFactory) {
  barButtonClickHandlerFactory = generator
}

function bindBarButtonClickEvent(sceneId: string, item: object | null | undefined): object | null {
  if (item === null || item === undefined) {
    return null
  }

  return JSON.parse(
    JSON.stringify(item, (key, value) => {
      if (key !== 'action' || typeof value !== 'function') {
        return value
      }

      const actionKey = 'ON_BAR_BUTTON_ITEM_CLICK_' + actionIdGenerator++

      if (!keyPairs[sceneId]) {
        keyPairs[sceneId] = []
      }
      keyPairs[sceneId].push(actionKey)
      actions[actionKey] = value

      return actionKey
    }),
  )
}

function removeBarButtonClickEvent(sceneId: string): void {
  const keys = keyPairs[sceneId]
  delete keyPairs[sceneId]
  if (keys) {
    keys.forEach(key => delete actions[key])
  }
}

listenBarButtonItemClick((sceneId: string, action: string) => {
  const listeners = actions
  if (listeners[action]) {
    const handler = barButtonClickHandlerFactory()
    handler(sceneId, listeners[action])
  }
})

export default {
  listenStatusBarHeightChanged,
  listenComponentResult,
  listenComponentVisibility,
  listenSwitchTab,
  listenSetRoot,
  bindBarButtonClickEvent,
  removeBarButtonClickEvent,
  setBarButtonClickHandlerFactory,
}
