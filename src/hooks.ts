import { useEffect, useState } from 'react'

import {
  EventEmitter,
  EVENT_NAVIGATION,
  KEY_SCENE_ID,
  KEY_ON,
  ON_COMPONENT_DISAPPEAR,
  ON_COMPONENT_APPEAR,
} from './NavigationModule'
import { Navigator } from './Navigator'

export type Visibility = 'visible' | 'invisible' | 'pending'

export function useVisible(sceneId: string) {
  const visibility = useVisibility(sceneId)
  return visibility === 'visible'
}

export function useVisibility(sceneId: string) {
  const [visibility, setVisibility] = useState(Navigator.of(sceneId).visibility)

  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          setVisibility('visible')
        } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          setVisibility('invisible')
        }
      }
    })

    return () => {
      subscription.remove()
    }
  }, [sceneId])

  return visibility
}
