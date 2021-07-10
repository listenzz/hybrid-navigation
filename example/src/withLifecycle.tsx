import { useVisible } from 'hybrid-navigation'
import React, { useEffect, useRef } from 'react'

export interface Lifecycle {
  componentDidAppear: () => void
  componentDidDisappear: () => void
}

export function withLifecycle(ClassComponent: React.ComponentClass<any>) {
  const FC = (props: any) => {
    const visible = useVisible(props.sceneId)
    const ref = useRef<React.Component & Lifecycle>(null)

    useEffect(() => {
      if (!visible) {
        return
      }

      if (ref.current?.componentDidAppear) {
        ref.current.componentDidAppear()
      }

      const current = ref.current
      return () => {
        if (current?.componentDidDisappear) {
          current.componentDidDisappear()
        }
      }
    }, [visible])

    return <ClassComponent ref={ref} {...props} />
  }

  FC.navigationItem = (ClassComponent as any).navigationItem
  const name = ClassComponent.displayName || ClassComponent.name
  FC.displayName = `withLifecycle(${name})`

  return FC
}
