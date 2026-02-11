# 可见性监听

页面的「可见」指用户当前看到的栈顶页面；从 A push 到 B 时，A 变为不可见，B 变为可见；pop 回 A 时反之。可用于刷新列表、暂停播放、埋点等。

## useVisibleEffect

在函数组件中监听**当前页面**的显示与隐藏：页面变为可见时执行回调，返回的清理函数在页面变为不可见时执行。

```tsx
import { View } from 'react-native';
import { useVisibleEffect } from 'hybrid-navigation';

function MyScreen() {
  useVisibleEffect(() => {
    console.log('页面可见');
    return () => console.log('页面不可见');
  });
  return <View>...</View>;
}
```

注意：`useVisibleEffect` 内部依赖 `useNavigator()`，因此必须在已挂载到 hybrid-navigation 的页面组件内使用（即通过 `Navigation.registerComponent` 注册的、被 `withNavigationItem` 等包裹的组件）。

## useNavigator

获取当前页面对应的 `Navigator` 实例（与 props 中的 `navigator` 一致），用于在无法从 props 拿到 navigator 的深层子组件中执行导航。

```tsx
import { useNavigator } from 'hybrid-navigation';

function Child() {
  const navigator = useNavigator();
  return (
    <Button onPress={() => navigator.push('Detail')} title="进入详情" />
  );
}
```

仅在已注册的页面组件及其子组件树内有效。

## 高级：按 sceneId 监听（addVisibilityEventListener）

若需要在**页面外**根据 `sceneId` 监听某页面的可见性（例如在 Store 或服务层），可使用：

```ts
import Navigation from 'hybrid-navigation';

const subscription = Navigation.addVisibilityEventListener(sceneId, (visibility) => {
  if (visibility === 'visible') {
    // 该页面变为可见
  } else {
    // 该页面变为不可见
  }
});

// 取消监听
subscription.remove();
```

`visibility` 取值为 `'visible'` | `'invisible'` | `'pending'`。

## 全局可见性（addGlobalVisibilityEventListener）

监听任意页面的可见性变化，用于统一埋点、统计等：

```ts
import Navigation from 'hybrid-navigation';

const subscription = Navigation.addGlobalVisibilityEventListener((sceneId, visibility) => {
  console.log(`scene ${sceneId} -> ${visibility}`);
});
subscription.remove();
```
