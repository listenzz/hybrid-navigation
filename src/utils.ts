import {
  EventEmitter,
  EVENT_NAVIGATION,
  KEY_ACTION,
  KEY_SCENE_ID,
  KEY_ON,
  ON_BAR_BUTTON_ITEM_CLICK,
} from './NavigationModule'
import { Navigator } from './Navigator'
import store from './store'

let actionIdGenerator = 0

export interface BindOptions {
  inLayout?: boolean
  sceneId?: string | undefined
  navigatorFactory?: (sceneId: string) => Navigator
}

function bindBarButtonItemClickEvent(
  item: object | null | undefined,
  options: BindOptions = { inLayout: false },
): JSON | null {
  if (options.inLayout) {
    removeBarButtonItemClickEventInLayout()
  }
  if (item === null || item === undefined) {
    return null
  }
  return JSON.parse(
    JSON.stringify(item, (key, value) => {
      if (key === 'action' && typeof value === 'function') {
        const action = 'ON_BAR_BUTTON_ITEM_CLICK_' + actionIdGenerator++

        let event = EventEmitter.addListener(
          EVENT_NAVIGATION,
          data => {
            if (data[KEY_ON] === ON_BAR_BUTTON_ITEM_CLICK && data[KEY_ACTION] === action) {
              let navigator = store.getNavigator(data[KEY_SCENE_ID])
              if (!navigator && options.inLayout && options.navigatorFactory) {
                navigator = options.navigatorFactory(data[KEY_SCENE_ID])
              }
              navigator && value(navigator)
            }
          },
          {},
        )

        if (options.inLayout) {
          event.context.inLayout = true
        }
        event.context.sceneId = options.sceneId

        store.addBarButtonItemClickEvent(event)

        return action
      }
      return value
    }),
  )
}

function removeBarButtonItemClickEventInLayout(): void {
  store
    .filterBarButtonItemClickEvent(event => !!event.context.inLayout)
    .forEach(event => {
      store.removeBarButtonItemClickEvent(event)
    })
}

function removeBarButtonItemClickEvent(sceneId: string): void {
  store
    .filterBarButtonItemClickEvent(
      event => event.context.sceneId && event.context.sceneId === sceneId,
    )
    .forEach(event => {
      store.removeBarButtonItemClickEvent(event)
    })
}

export { bindBarButtonItemClickEvent, removeBarButtonItemClickEvent }
