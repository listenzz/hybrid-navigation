# 额外的生命周期回调函数

为类组件提供了额外的生命周期回调函数

- componentDidAppear

当页面可见时回调，确保在 componentDidMount 之后回调

- componentDidDisappear

当页面不可见时回调

> 从 A 页面切换至 B 页面时，确保 A 页面的 componentDidDisappear 在 B 页面的 componentDidAppear 之前执行

- onComponentResult(requestCode, resultCode, data)

当从前一个页面返回结果时回调，包含 pop、dismiss、hideModal 等操作。

> onComponentResult 总是在该页面的 componentDidAppear 之后执行

- onBackPressed

仅对 Android 平台生效。用于处理通过 showModal 弹出的注册组件的物理或虚拟返回键。

## 为函数组件提供了 React Hooks

```javascript
function Lifecycle(props) {
  useVisibleEffect(props.sceneId, () => {
    // 等同于 componentDidAppear
    return () => {
      // 等同于 componentDidDisappear
    };
  });
```

`useBackEffect` 等同于 `onBackPressed`

`useResult` 等同于 `onComponentResult`

## 注意

如果使用了 [HOC](https://reactjs.org/docs/higher-order-components.html) 技术包裹了导出的组件，想要触发生命周期事件，请确保该 HOC [正确转发了引用](https://reactjs.org/docs/forwarding-refs.html)。

譬如使用了 Redux，想要正确触发生命周期事件，需要像下面那样使用 `connect` 函数

```javascript
export default connect(
  mapStateToProps,
  mapDispatchToProps,
  undefined,
  { forwardRef: true } // 注意这行代码，开启引用转发功能
)(ReduxCounter);
```

详情请查看 playground/src/ReduxCounter.js 这个文件
