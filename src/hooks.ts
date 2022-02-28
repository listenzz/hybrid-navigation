import React, { useContext, useEffect, useRef, useState } from 'react'

import {
  EVENT_NAVIGATION,
  EventEmitter,
  KEY_ON,
  KEY_SCENE_ID,
  ON_COMPONENT_APPEAR,
  ON_COMPONENT_DISAPPEAR,
} from './NavigationModule'
import { Navigator } from './Navigator'
import { NavigationContext } from './ReactRegistry'

export type Visibility = 'visible' | 'invisible' | 'pending'

export function useVisible() {
  const visibility = useVisibility()
  return visibility === 'visible'
}

export function useVisibility() {
  const navigator = useNavigator()
  const [visibility, setVisibility] = useState(navigator.visibility)

  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (navigator.sceneId === data[KEY_SCENE_ID]) {
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
  }, [navigator])

  return visibility
}

export function useVisibleEffect(effect: React.EffectCallback) {
  const navigator = useNavigator()
  const destructor = useRef<ReturnType<React.EffectCallback>>()

  useEffect(() => {
    if (navigator.visibility === 'visible') {
      destructor.current = effect()
    }

    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (navigator.sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          destructor.current = effect()
        } else if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          if (destructor.current) {
            destructor.current()
            destructor.current = undefined
          }
        }
      }
    })

    return () => {
      if (destructor.current) {
        destructor.current()
        destructor.current = undefined
      }
      subscription.remove()
    }
  }, [effect, navigator])
}

export function useNavigator(): Navigator {
  return useContext<Navigator>(NavigationContext)
}

export function useGarden() {
  const ctx = useContext<Navigator>(NavigationContext)
  return ctx.garden
}
