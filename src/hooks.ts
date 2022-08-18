import React, { useContext, useEffect, useRef, useState } from 'react'
import Navigation from './Navigation'

import { Navigator, NavigationContext } from './Navigator'

export function useVisible() {
  const visibility = useVisibility()
  return visibility === 'visible'
}

export function useVisibility() {
  const navigator = useNavigator()
  const [visibility, setVisibility] = useState(navigator.visibility)

  useEffect(() => {
    const subscription = Navigation.addVisibilityEventListener(navigator.sceneId, v => {
      setVisibility(v)
    })
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

    const subscription = Navigation.addVisibilityEventListener(navigator.sceneId, visibility => {
      if (visibility === 'visible') {
        destructor.current = effect()
      } else {
        destructor.current && destructor.current()
        destructor.current = undefined
      }
    })

    return () => {
      destructor.current && destructor.current()
      destructor.current = undefined
      subscription.remove()
    }
  }, [effect, navigator])
}

export function useNavigator(): Navigator {
  return useContext<Navigator>(NavigationContext)
}

/**
 * @deprecated Use Navigation related methods instead.
 * @returns
 */
export function useGarden() {
  const ctx = useContext<Navigator>(NavigationContext)
  return ctx.garden
}
