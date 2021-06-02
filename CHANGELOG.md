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
