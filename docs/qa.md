# 常见问题

## 如何和 `React.Context` 一起使用

`React.Context` 使得具有相同根组件的所有子组件共享上下文。可是 hybrid-navigation 的每一个页面都是独立的，它们没有共同的根组件，那么，如何才能在 hybrid-navigation 环境下使用 `React.Context` 呢？

请参考 [ContextDemo](https://github.com/listenzz/MultiContextDemo)。

> :white_check_mark: 推荐使用 [zustand](https://github.com/pmndrs/zustand)

## 推荐使用 FastImage 代替 Image 组件

为什么在 Android 平台，push 到下一个页面时，当前页面的图片会消失？

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
};
```

## 如何拦截 Android 物理返回键

```ts
useVisibleEffect(
  useCallback(() => {
    const handleBackPress = () => {
      console.log('---------------');
      // true 表示拦截，false 表示不拦截
      return false;
    };

    BackHandler.addEventListener('hardwareBackPress', handleBackPress);
    return () => BackHandler.removeEventListener('hardwareBackPress', handleBackPress);
  }, []),
);
```

## 如何实现 HOC

:exclamation: 实现 [HOC](https://zh-hans.reactjs.org/docs/higher-order-components.html) 时，注意传递 props 给被包裹的组件，以及注意复制 `navigationItem` 这个静态属性，如

```ts
export function withRedux(WrappedComponent: ComponentType<any>) {
  return class ReduxProvider extends React.Component {
    // 注意复制 navigationItem
    static navigationItem = (WrappedComponent as any).navigationItem;

    static displayName = `withRedux(${WrappedComponent.displayName})`;

    render() {
      return (
        <Provider store={store}>
          // 注意传递 props 属性
          <WrappedComponent {...this.props} />
        </Provider>
      );
    }
  };
}
```
