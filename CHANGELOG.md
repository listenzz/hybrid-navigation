## 2.7.1 (2022-01-05)

### iOS specific

- 修复 iOS 15.2 下，自定义返回图标无效的问题

## 2.7.0（2021-12-28）

### Android specific

- 支持 appcompat 1.3

## 2.6.0 (2021-11-29)

- 支持动态设置 `screenBackgroundColor`

## 2.5.1 (2021-11-09)

### Android specific

- 修复导致键盘 `adjustResize` 模式无效的问题

## 2.5.0 (2021-11-04)

- 添加 `Garden#setTabItem`，可以动态修改 tab 图标，标题，徽章。

- 弃用 `Garden#setTabIcon`

- 弃用 `Garden#setTabBadge`

## 2.4.3 (2021-11-03)

### iOS specific

- 优化导航栏实现

- 移除对 CallKit 的依赖，避免应用商店审核问题

## 2.4.2 (2021-10-08)

### iOS specific

- 适配 iOS 15

## 2.4.1 (2021-10-08)

### iOS specific

- 适配 iOS 15

## 2.4.0 (2021-09-22)

### iOS specific

- 适配 iOS 15

## 2.3.0 (2021-09-16)

### iOS specific

- 支持和 `react-native-gesture-handler` 一起使用

  如果需要支持 react-native-gesture-handler， 需要按如下方式修改 AppDelegate.m 文件

  ```objc
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  [[HBDReactBridgeManager get] installWithBridge:bridge];
  ```

- 添加 `homeIndicatorAutoHiddenIOS` 配置项，仅对页面可设置，可以动态变更，用于隐藏该页面的 Home 指示器

## 2.2.0 (2021-09-15)

### Android specific

- 支持隐藏虚拟导航栏

  `navigationBarHiddenAndroid` 默认为 false，仅对页面可设置，可以动态变更

- 支持 Android 9 及以上，设置横屏时，是否将页面延伸至开口区域

  `displayCutoutWhenLandscapeAndroid` 默认为 true，可以全局设置，也可仅针对某页面设置。

## 2.1.2 （2021-09-10）

- 处理透明导航栏在 Android 10 的兼容性问题

## 2.1.1

- 适配 RN 0.65

## 2.1.0

- `useVisible` 不再需要参数

- 添加 `useNavigator`

  ```tsx
  const navigator = useNavigator()
  ```

- 添加 `useGarden`

- 重新设计 `useVisibleEffect`，现在它接受一个 useCallback 作为参数，是不是很酷？

  ```tsx
  useVisibleEffect(
    useCallback(() => {
      console.info(`Page ReactModal is visible [${sceneId}]`)
      return () => console.info(`Page ReactModal is invisible [${sceneId}]`)
    }, [sceneId]),
  )
  ```

## 2.0.0

- 移除 `useResult`，请使用 `React.Context` 或 `Redux` 等技术代替

  这里有一个关于[如何在 hybrid-navigation 中使用 React.Context](https://github.com/listenzz/MultiContextDemo) 的例子。

- 移除 `useVisibleEffect`，使用如下方式代替

```tsx
import React, { useCallback } from 'react'
import { useVisible } from 'hybrid-navigation'

const visible = useVisible(sceneId)

useEffect(() => {
  if (!visible) {
    return
  }

  Alert.alert('Lifecycle Alert!', 'componentDidAppear.')
  return () => Alert.alert('Lifecycle Alert!', 'componentDidDisappear.')
}, [visible])
```

## 1.8.1

- 修正 `NavigationInterceptor` 中的 `Extras` 类型定义

## 1.8.0

- 添加 `Garden#setLeftBarButtonItems` 和 `Garden#setRightBarButtonItems`

## 1.7.3

- 通过 router 切换 tab 时，调用当前 stack 的 `popToRoot`

### iOS specific

- 处理关闭 drawer 时，因页面状态栏样式不同导致的偶尔闪烁问题

### Android specific

- 延迟释放伪 TabBar，避免偶尔出现的闪烁问题
- 设置 Modal 的状态栏默认样式为白色，和 Alert 保持一致
- 确保在主线程设置生命周期状态

## 1.7.0

### BreakChanges

- 路由 Handler 现在返回一个 Promise，这是为了可以将 Result 派发到正确的页面

- 重新设计 Result 相关实现，移除了 `requestCode` 参数，受影响的 API 有 `useResult`，`present`，`showModal`

### Android specific

- 添加 `scrimAlphaAndroid` 属性，用于配置侧滑返回的遮罩效果

- 动画文件名称变更

## 1.6.4

- 处理 stack 路由存在的问题

## 1.6.3

- 处理 stack 路由的 child 可能不是 screen 的问题

## 1.6.2

### Android specific

- 处理因过早使用 `style` 中的属性，而可能导致的 NPE 问题

## 1.6.1

### iOS specific

- 修复开启 `splitTopBarTransitionIOS` 后，present 会导致 TopBar 上覆盖一层蒙版的问题

## 1.6.0

### Android specific

- 优化 TabBar 可见性在页面转场时的效果，更好地支持自定义转场动画

### iOS specific

- 添加 `splitTopBarTransitionIOS` 属性，支持 TopBar 在转场时总是分离效果

## 1.5.0

### Android specific

- 底层库迁移到 mavenCentral

如果你使用 1.5.0 以上版本，需要修改 android/build.gradle 文件，添加 mavenCentral()

```groovy
allprojects {
    repositories {
        mavenLocal()
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url("$rootDir/../node_modules/react-native/android")
        }
        maven {
            // Android JSC is installed from npm
            url("$rootDir/../node_modules/jsc-android/dist")
        }
        google()
        jcenter()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

## 1.4.7

### Android specific

- 修复调用 `setRoot` 时，不正常抛 `IllegalStateException` 的问题

## 1.4.6

- 优化 stack 路由选择，当 props 为空对象时，pop 到现有页面而不是 redirect

## 1.4.5

### BreakChanges

- 重命名 `DeepLink.inactive` 为 `DeepLink.deactive`

## 1.4.4

- 修复 Auto-linking

## 1.4.3

- 修正了 peer dependencies，以适应 RN0.64

### iOS specific

- 修复某些设备状态栏没有按声明那样隐藏的问题

## 1.4.2

### Android specific

- 修复 TabBar 可能非正常消失的问题

## 1.4.1

### BreakChanges

- 重新定义了 `Navigator.setInterceptor`

## 1.3.1

### Android specific

- 修复当当前页面类型为 modal 时，`Navigator.current` 未能获取到正确的 navigator 的问题

## 1.3.0

- 添加第二个参数 `inclusive` 到 `popTo`，指示要不要把第一个参数所代表的页面也一起出栈，默认是 `false`，和原来逻辑保持一致。

## 1.2.2

### iOS specific

- 修复切换 TAB 时，生命周期事件触发顺序不正确的问题

- 修复在 UI 层级尚未就绪的情况下，`Navigator.find` 返回 `undefined` 的问题

## 1.2.1

- 修复当存在原生页面时，`routeGroup` 和 `currentRoute` 的崩溃问题

## 1.2.0

- 修复当 definesPresentationContext 开启时，`routeGroup` 和 `currentRoute` 存在的问题

## 1.1.0

- 将 \*/build/ 添加到 .npmignore

- 重新设计了 Navigator 接口

- 优化了 `routeGroup` 和 `currentRoute` 的实现

## 1.0.0

- `Navigator.get` 重命名为 `Navigator.of`
