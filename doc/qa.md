# 常见问题

## 如何和 `React.Context` 一起使用

`React.Context` 使得具有相同根组件的所有子组件共享上下文。可是 hybrid-navigation 的每一个页面都是独立的，它们没有共同的根组件，那么，如何才能在 hybrid-navigation 环境下使用 `React.Context` 呢？

请参考 [ContextDemo](https://github.com/listenzz/MultiContextDemo)。

## 为什么在 Android 平台，push 到下一个页面时，当前页面的图片会消失？

细心的同学，可能会注意到，在 Android 平台，push 到下一个页面时，当前页面的图片会消失。这是怎么回事呢？

这是由于 React Native 底层使用的图片加载库是 Fresco。Fresco 做了过度优化，会把不可见页面的图片隐藏掉。

相关 [issue](https://github.com/facebook/fresco/issues/1841)。

推荐使用 [FastImage](https://github.com/DylanVann/react-native-fast-image) 替换掉 ReactNative 自带的 Image 组件

为了避免误用 Image 组件，可以在 eslintrc 中加入如下规则

```js
module.exports = {
  rules: {
    'no-restricted-imports': [
      'error',
      {
        paths: [
          {
            name: 'react-native',
            importNames: ['Image'],
            message: '请使用 FastImage 替代 Image',
          },
        ],
      },
    ],
  },
}
```

## 使用类组件时，如何监听页面可见性？

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
