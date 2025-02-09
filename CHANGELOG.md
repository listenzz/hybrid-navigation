## 2.17.7 - 2.17.10

### Android specific

- 处理横竖屏切换，界面可能不销毁的问题

## 2.17.6

- 支持设置页面为横屏

## 2.17.5

### Android specific

- 处理 Modal 未能正确设置状态栏样式的问题

## 2.17.4

### Android specific

- 修复 Modal 导致底下页面状态变为不可见的问题

## 2.17.3

### Android specific

- 底部导航栏字体大小不跟随系统字体大小变化

## 2.17.2 （2024-10-18）

### iOS specific

- 修复 iOS 18 下，fake navigation bar 未能正确设置的问题

## 2.17.1 （2024-09-21）

- 修复 present result 未能正确派发的问题
- 兼容 iOS 18

## 2.17.0 （2024-07-06）

- 移除已启用方法和属性

### iOS specific

- 当隐藏返回按钮文字时，关闭返回按钮长案菜单

## 2.16.11 (2024-03-28)

### Android specific

- 处理编译问题 #255 #253

## 2.16.10 (2024-03-14)

### iOS specific

- 处理 iOS17 测滑返回时状态栏样式表现不正常的问题

## 2.16.9 (2024-02-04)

### Android specific

- 处理 Android11 系统 UI 兼容性问题

## 2.16.8 （2024-02-02）

- 简化了 `useVisibleEffect` 的实现

- 处理 Android12 系统 UI 兼容性问题

## 2.16.7 (2023-09-01)

### Android specific

- 修复冷重启导致的崩溃问题

## 2.16.5 - 2.16.6 (2023-07-29)

### Android specific

- 处理隐私政策相关问题

## 2.16.4 (2023-07-19)

### Android specific

- 修复自定义 TitleView 没有显示的问题

## 2.16.3 (2023-06-19)

### Android specific

- 处理 `TabBar` 的 WindowInsets 相关问题

## 2.16.2 (2023-06-15)

- 处理 `Navigation` 在 WebStorm 的 import 提示问题

## 2.16.1 (2023-06-12)

### Android specific

- 处理 Fragment already added and state has been saved

## 2.16.0 (2023-05-19)

- 延迟初始化 drawer#menu

## 2.15.15 (2023-05-15)

### Android specific

- 处理重定向时未关闭键盘的问题

## 2.15.13 - 2.15.14 (2023-05-11)

### Android specific

- 处理 drawer#menuInteractive 在某些情况下，表现不正常的问题

## 2.15.12 (2023-05-10)

### Android specific

- 处理某些情况下，退出页面时，键盘未能正确收起的问题

## 2.15.11 (2023-05-10)

### Android specific

- 优化了对 windowInsets 的处理，避免 ReactRootView 高度发生变化

## 2.15.10 (2023-05-09)

### Android specific

- 默认适配不透明导航栏的边衬区，即 `fitsOpaqueNavigationBarAndroid` 的默认值现在为 `true`。

## 2.15.9 (2023-04-20)

### Android specific

- 优化 drawer 的 `menuInteractive` 实现

## 2.15.8 (2023-04-20)

### Android specific

- 处理 Activity 销毁重建时，drawer 表现不正常的问题

  > 设置系统字体大小等会导致 Activity 销毁重建

## 2.15.7 (2023-04-20)

### iOS specific

- 处理在 push 时触动手势 pop 导致页面卡死的问题

- 处理 Text Bar Button 在 pop 回来时，大小表现不正常的兼容性问题

## 2.15.6 (2023-04-19)

### iOS specific

- 处理 drawer menu 在快速切换时，未能释放前一个 dimming view 的问题

## 2.15.5 (2023-03-20)

### Android specific

- 允许全局设置是否适配不透明的导航栏边衬区，默认为 false

  ```tsx
  Navigation.setDefaultOptions({
    // 默认是 false，这意味着开发者需要使用 SafeAreaView 来规避系统 UI 的遮挡
    fitsOpaqueNavigationBarAndroid: false,
  })
  ```

## 2.15.4 (2023-03-18)

### Android specific

- 处理 `Fragment not attached to an activity` 的问题

## 2.15.3 (2023-03-15)

### Android specific

- 处理 `Fragment did not return a View from onCreateView or this was called before onCreateView` 的问题

## 2.15.0 - 1.15.2 (2023-02-25)

### Android specific

- 允许通过 `fitsOpaqueNavigationBarAndroid` 设置是否适配不透明的导航栏边衬区，默认为 false

  ```tsx
  export default withNavigationItem({
    // 默认是 false，这意味着开发者需要使用 SafeAreaView 来规避系统 UI 的遮挡
    fitsOpaqueNavigationBarAndroid: false,
  })
  ```

## 2.14.6 (2023-02-16)

### Android specific

- 处理自定义 TabBar 兼容性问题

## 2.14.5 (2023-02-15)

### Android specific

- 处理 `FragmentManager is already executing transactions` 问题

## 2.14.4 (2023-02-15)

### Android specific

- 处理 Android 11 状态栏和导航栏样式兼容性问题

## 2.14.3 (2023-02-15)

### Android specific

- 处理自定义容器 TabBar 边衬区的问题

## 2.14.2 (2023-02-13)

### Android specific

- 处理 Android 11 状态栏和导航栏背景、样式相关兼容性问题

## 2.14.1 (2023-02-11)

### Android specific

- 修复了对 RN0.63 的兼容性问题

- 修复了自定义 TabBar 未适配 WindowInsets API 的问题

## 2.14.0 (2023-02-02)

### Android specific

- 支持 WindowInsets API

  建议使用 [keyboard-insets](https://github.com/sdcxtech/react-native-troika/blob/master/packages/keyboard-insets/README.md) 来处理键盘相关。

  建议使用 [react-native-safe-area-context](https://github.com/th3rdwave/react-native-safe-area-context) 来规避系统 UI 的遮挡。

## 2.13.18 (2023-01-11)

### Android specific

- 优化 Android 底层实现，提升性能和稳定性

## 2.13.16 - 2.13.17 (2022-12-15)

### Android specific

- 处理 `ReactAppCompatActivity` 没能正确重建的问题（这会导致白屏）

## 2.13.11 - 2.13.15 (2022-11-09)

### Android specific

- 处理 App 处于后台时，在同一页面多次 `redirectTo` 动作不正常的问题

## 2.13.10 (2022-10-30)

### Android specific

- 修复热重启时潜在的问题

## 2.13.9 (2022-09-29)

- 仅仅优化代码，API 不变

## 2.13.8 (2022-09-06)

### Android specific

- 支持延迟初始化 RN

在 MainApplication 中作如下变更：

```diff
  ReactBridgeManager bridgeManager = ReactBridgeManager.get();
- bridgeManager.install(getReactNativeHost());
+ bridgeManager.setReactNativeHost(getReactNativeHost());
```

然后在适当时机（譬如用户同意隐私政策后）调用 `bridgeManager.initialize()`

## 2.13.6 (2022-09-01)

### iOS specific

- 修复应用启动时通过 sceneId 找不到对应 UIViewController 的问题

## 2.13.5 (2022-08-24)

### Android specific

- 允许在后台时返回路由图

## 2.13.4 (2022-08-23)

### iOS specific

- 兼容 hybrid-navigation-deck

## 2.13.3 (2022-08-22)

- 补全了因为重构而丢失的路由信息（from, to）

- 优化了 `setRoot` 的实现

## 2.13.2 (2022-08-19)

### Android specific

- 修复非初始选中 Tab 页面底部 padding 未能设置的问题

## 2.13.1 (2022-08-19)

- 重构了 Router 相关的代码，使其更加简洁易懂。

- 移除了 Router 中重复的 API。

## 2.13.0 (2022-08-17)

- 添加 `statusBarHeight()`、`toolbarHeight()`、`topBarHeight()` 几个方法用来获取状态栏、工具栏、顶部栏的高度

  ```ts
  import { statusBarHeight, toolbarHeight, topBarHeight } from 'hybrid-navigation'
  ```

- 标记 `Garden`、`ReactRegistry` 为弃用，使用 `Navigation` 对象对应的方法代替

  ```ts
  import Navigation from 'hybrid-navigation'
  import App from './App'

  Navigation.registerComponent('App', () => App)
  ```

- 标记 `Navigator` 中的大部分静态方法为弃用，使用 `Navigation` 对象对应的方法代替

  ```ts
  import Navigation from 'hybrid-navigation'

  Navigation.setRoot({})
  ```

- 处理了切换页面时，TextInput 自动获取焦点弹出键盘导致的问题

## 2.12.4 （2022-08-02）

### iOS specific

- 修复由后台返回前台，导航栏分割线会闪烁的问题

## 2.12.3 （2022-07-26）

### iOS specific

- 处理和 C++ 关键字冲突的问题 (by @devvit)

## 2.12.2 （2022-06-21）

### Android specific

- 修复按返回键退出 Modal 时，没有使用淡出动画的问题

## 2.12.0 （2022-06-16）

- 给 Modal 添加淡入淡出动画

## 2.11.2 （2022-06-11）

### Android specific

- 修复 `navigationBarColorAndroid` 可能存在的问题

## 2.11.1 （2022-06-02）

- 更改 Modal 的实现。现在 Android 的 Modal 由 Fragment 实现，而不再是 Dialog，iOS 的 Modal 由 UIViewController 实现，而不再是 Window。

## 2.10.2 （2022-06-02）

### Android specific

- 修复 `navigationBarHiddenAndroid` 参数对 TabBar 不生效的问题

## 2.10.1 (2022-05-31)

- 更新 typings

## 2.10.0 (2022-05-31)

- 当 `screenBackgroundColor` 包含透明度时，对 Modal 生效

```ts
export default withBottomModal({ safeAreaColor: '#F3F3F3' })(
  withNavigationItem({
    // forceTransparentDialogWindow: true,
    screenBackgroundColor: '#33000000',
  })(ReactModal),
)
```

`forceTransparentDialogWindow` 会覆盖 `screenBackgroundColor`，使得 Modal 全透明，并尝试适配状态栏的颜色

## 2.9.0 (2022-05-11)

- 调整传递给 `ReactRegistry.startRegisterComponent` 的 [HOC](https://zh-hans.reactjs.org/docs/higher-order-components.html) 的使用顺序，现在可以通过以下方式全局设置页面特定属性：

  ```js
  ReactRegistry.startRegisterComponent(withNavigationItem({ topBarHidden: true }))
  ```

  :exclamation: 实现 HOC 时，注意传递 props 给被包裹的组件，以及注意复制 `navigationItem` 这个静态属性，如

  ```ts
  export function withRedux(WrappedComponent: ComponentType<any>) {
    return class ReduxProvider extends React.Component {
      // 注意复制 navigationItem
      static navigationItem = (WrappedComponent as any).navigationItem

      static displayName = `withRedux(${WrappedComponent.displayName})`

      render() {
        return (
          <Provider store={store}>
            // 注意传递 props 属性
            <WrappedComponent {...this.props} />
          </Provider>
        )
      }
    }
  }
  ```

## 2.8.3 (2022-05-05)

### Android

- 修复 reload 时，会重复 run application 的问题

## 2.8.2 （2022-04-27）

### iOS specific

- 修复由于隐藏 back title 而导致 back icon 在转场时表现异常的问题

## 2.8.1 (2022-04-25)

### iOS specific

- 优化 `redirectTo` 路由实现，避免在转场过程中执行新的路由动作

## 2.8.0 （2022-04-13）

- 添加 `forceTransparentDialogWindow` 配置项，用于设置当页面是 Dialog 时，是否强制背景透明

## 2.7.11 (2022-04-13)

### Android specific

- 确保在 Activity 处于 start 状态时，才获取 `currentRoute` 和 `routeGraph`

## 2.7.10 (2022-04-12)

- 使用 `CompanentType<any>` 代替 `React.ComponentType<any>`

## 2.7.9 (2022-03-23)

### Android specific

- 修复 `Fragment is not an active fragment of FragmentManager`

## 2.7.8 (2022-03-03)

### ios specific

- 修复因 NSUInteger 导致的问题

```objc
    for (NSUInteger i = count - 1; i > -1; i--) {
        // 无法进入此区间
    }
```

## 2.7.7 (2022-03-03)

### Android specific

- 修复因 2.7.6 导致的侧滑返回时，页面闪烁的问题

## 2.7.6 (2022-03-02)

### Android specific

- 再修复 `FragmentManager is already executing transactions`

## 2.7.5 (2022-02-21)

### Android specific

- 修复 `IllegalStateException: Fragment not associated with a fragment manager.`

## 2.7.4 (2022-02-14)

### Android specific

- 修复 `FragmentManager is already executing transactions`

### iOS specific

- 确保生命周期函数执行顺序

## 2.7.3 (2022-02-10)

### Android specific

- 修复 `Can not perform this action after onSaveInstanceState`

## 2.7.2 (2022-01-10)

### Android specific

- 修复调用 `setDefinesPresentationContext` 导致空指针的问题

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
