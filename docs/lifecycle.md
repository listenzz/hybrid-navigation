# 可见性监听

## 如何监听页面显示或隐藏

使用 `useVisibleEffect`

```tsx
import React, { useCallback } from 'react'
import { useVisibleEffect } from 'hybrid-navigation'

useVisibleEffect(
  useCallback(() => {
    Alert.alert('Lifecycle Alert!', 'componentDidAppear.')
    return () => Alert.alert('Lifecycle Alert!', 'componentDidDisappear.')
  }, []),
)
```

如果需要获取页面可见状态，使用 `useVisible` 或者 `useVisibility`。

```ts
import React, { useEffect } from 'react'
import { useVisible } from 'hybrid-navigation'

const MyComponent = () => {
  const visible = useVisible()

  useEffect(() => {
    if (!visible) {
      return
    }
    console.info('页面可见')

    return () => {
      console.info('页面不可见')
    }
  }, [visible])

  return <View />
}
```

## 类组件

本项目中的例子几乎都是用函数组件示例的，因为这是趋势，历史的车轮滚滚向前，该忘掉的就忘掉，该丢弃的就丢弃。

有时由于历史遗留问题，不得不使用类组件，此时如何监听页面可见性呢？

自定义一个 [HOC](https://reactjs.org/docs/higher-order-components.html)

```tsx
export interface Lifecycle {
  componentDidAppear: () => void
  componentDidDisappear: () => void
}

export function withLifecycle(ClassComponent: React.ComponentClass<any>) {
  const FC = (props: any) => {
    const ref = useRef<React.Component & Lifecycle>(null)

    useVisibleEffect(
      useCallback(() => {
        if (ref.current?.componentDidAppear) {
          ref.current.componentDidAppear()
        }

        const current = ref.current
        return () => {
          if (current?.componentDidDisappear) {
            current.componentDidDisappear()
          }
        }
      }, []),
    )

    return <ClassComponent ref={ref} {...props} />
  }

  FC.navigationItem = (ClassComponent as any).navigationItem
  const name = ClassComponent.displayName || ClassComponent.name
  FC.displayName = `withLifecycle(${name})`

  return FC
}
```

在类组件中添加 `componentDidAppear` 和 `componentDidDisappear` 两个实例方法，使用 `withLifecycle` 包裹类组件并导出，如下所示

```tsx
class MyClassComponent extends React.Component<InjectedProps> implements Lifecycle {
  static navigationItem: NavigationItem = {
    titleItem: {
      title: '我的类组件',
    },
  }

  componentDidAppear() {
    console.info('MyClassComponent#componentDidAppear')
  }

  componentDidDisappear() {
    console.info('MyClassComponent#componentDidDisAppear')
  }
}

export default withLifecycle(MyClassComponent)
```
