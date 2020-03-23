import { useEffect, useState } from 'react'

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
import { AppStateStatus, AppState } from 'react-native'

export type Visibility = 'visible' | 'gone' | 'pending'

export function useVisibility(sceneId: string) {
  const navigator = Navigator.get(sceneId)
  const [visibility, setVisibility] = useState<Visibility>(navigator.visibility)
  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          setVisibility('visible')
        } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          setVisibility('gone')
        }
      }
    })
    return () => {
      subscription.remove()
    }
  }, [sceneId])
  return visibility
}

export function useVisibleChange(sceneId: string, onChange: (visible: boolean) => void) {
  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          onChange(true)
        } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          onChange(false)
        }
      }
    })
    return () => {
      subscription.remove()
    }
  }, [sceneId, onChange])
}

export function useAppStateChange(onChange: (newState: AppStateStatus) => void) {
  useEffect(() => {
    AppState.addEventListener('change', onChange)

    return () => {
      AppState.removeEventListener('change', onChange)
    }
  }, [onChange])
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
