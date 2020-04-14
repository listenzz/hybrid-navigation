import { useEffect, useRef, useState } from 'react'

import {
  EventEmitter,
  EVENT_NAVIGATION,
  KEY_SCENE_ID,
  KEY_ON,
  ON_COMPONENT_RESULT,
  ON_COMPONENT_DISAPPEAR,
  ON_COMPONENT_APPEAR,
  KEY_REQUEST_CODE,
  KEY_RESULT_CODE,
  KEY_RESULT_DATA,
} from './NavigationModule'
import { Navigator } from './Navigator'

export type Visibility = 'visible' | 'gone' | 'pending'

export function useVisible(sceneId: string) {
  const navigator = Navigator.get(sceneId)
  const [visible, setVisible] = useState(navigator.visibility === 'visible')

  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          setVisible(true)
        } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          setVisible(false)
        }
      }
    })

    return () => {
      subscription.remove()
    }
  }, [sceneId])

  return visible
}

export function useVisibleEffect(sceneId: string, effect: React.EffectCallback) {
  const navigator = Navigator.get(sceneId)
  const callback = useRef<(() => void) | void>()

  useEffect(() => {
    if (navigator.visibility === 'visible') {
      if (callback.current) {
        callback.current()
      }
      callback.current = effect()
    }

    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          callback.current = effect()
        } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          if (callback.current) {
            callback.current()
            callback.current = undefined
          }
        }
      }
    })

    return () => {
      subscription.remove()
    }
  }, [effect, sceneId, navigator])
}

export function useResult(
  sceneId: string,
  fn: (requestCode: number, resultCode: number, data: { [x: string]: any }) => void,
) {
  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID] && data[KEY_ON] === ON_COMPONENT_RESULT) {
        fn(data[KEY_REQUEST_CODE], data[KEY_RESULT_CODE], data[KEY_RESULT_DATA])
      }
    })

    return () => {
      subscription.remove()
    }
  }, [sceneId, fn])
}
