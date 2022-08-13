import React, { useContext, useEffect, useRef, useState } from 'react'

import Event from './Event'
import { Navigator, NavigationContext } from './Navigator'

export function useVisible() {
  const visibility = useVisibility()
  return visibility === 'visible'
}

export function useVisibility() {
  const navigator = useNavigator()
  const [visibility, setVisibility] = useState(navigator.visibility)

  useEffect(() => {
    const subscription = Event.listenComponentVisibility(
      (sceneId: string) => {
        if (sceneId === navigator.sceneId) {
          setVisibility('visible')
        }
      },
      (sceneId: string) => {
        if (sceneId === navigator.sceneId) {
          setVisibility('invisible')
        }
      },
    )
    return () => subscription.remove()
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

    const subscription = Event.listenComponentVisibility(
      (sceneId: string) => {
        if (sceneId === navigator.sceneId) {
          destructor.current = effect()
        }
      },
      (sceneId: string) => {
        if (sceneId === navigator.sceneId && destructor.current) {
          destructor.current()
          destructor.current = undefined
        }
      },
    )

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
