# react-native-navigation-hybrid

React Native Navigation that supports seamless navigation between Native and React.

![navigation-android](./screenshot/android.png)

## Running the Playground Project

To run the playground project, first clone this repo:

```shell
git clone git@github.com:listenzz/react-native-navigation-hybrid.git
cd react-native-navigation-hybrid
```

### run on Android

First, make sure that you have a simulator or device.

Then,

```shell
npm install
# &
npm start
```

Then, in another CLI window:

```shell
npm run run:android
```

[**Download demo apk**](https://raw.githubusercontent.com/listenzz/react-native-navigation-hybrid/master/screenshot/app-release.apk)

或通过扫描二维码安装 demo

![demo-qrcode](./screenshot/demo-qrcode.png)

### run on iOS

First,

```shell
npm install
# &
npm start
```

Then, in another CLI window:

```shell
npm run run:ios
```

## 特性

<a name="migrate-react"></a>

- 使用原生导航组件实现 React Native 页面间的导航，不仅具有更优的性能，而且使得 RN 页面具有原生质感
- 原生页面和 RN 页面共享路由， 使得它们之间相互跳转和传值轻而易举
- 内置 drawer, tabs, stack 标准容器，同时支持自定义容器和导航
- 支持 deep link

## 目录

#### [集成到以 RN 为主的项目](./doc/integration-react.md)

#### [为原生项目添加 RN 模块](./doc/integration-native.md)

#### [容器与导航](./doc/navigation.md)

#### [RN 页面与原生页面相互跳转和传值](./doc/pass-and-return-value.md)

#### [额外的生命周期函数](./doc/lifecycle.md)

#### [设置样式](./doc/style.md)

#### [DeepLink](./doc/deeplink.md)

## 最近更新日志

| React Native version(s) | Supporting Navigation version(s) | 发布日期   |
| ----------------------- | -------------------------------- | ---------- |
| >= 0.60                 | 0.17.23                          | 2019/11/26 |
| < 0.60                  | 0.16.13                          | 2019/11/11 |

### 0.16.x or 0.17.x

- `setRoot` 现在返回一个 Promise

- 完善泛型支持

- 支持 React Hooks，在函数组件中，使用 `useVisibleEffect` 代替 `componentDidAppear` 和 `componentDidDisappear`，使用 `useResult` 代替 `onComponentResult`，使用 `useBackEffect` 代替 `onBackPressed`

- `push` `present` 和 `showModal` 现在返回一个 Promise

### 0.14.x

- 修复 `unselectedIcon` 不生效的问题

- 现在可以通过 `Garden.setRightBarButtonItem(null)` 移除 topBar 上的按钮

- 优化了 `switchTab`、`setRoot` 的过渡效果

- 修复额外生命周期 `componentDidAppear` 派发不准确的问题

- [Android] 修复 Activity 冷重启的问题

- [Android] 优化当应用从后台进入前台时的事务执行顺序

- 自定义 TabBar 传递的数据发生变化，详见 [自定义 TabBar 文档](./doc/custom-tabbar.md)

- 优化和 `Garden` 相关的若干 api，详见 [style 文档](./doc/style.md)

### 0.13.x - 2019/06/18

- 修复和 react-native-code-push 协作偶尔导致的崩溃

- Android 迁移到 Java 8

如果你的 app/build.gradle 没有以下配置，请加上

```diff
android {
+    compileOptions {
+        sourceCompatibility JavaVersion.VERSION_1_8
+        targetCompatibility JavaVersion.VERSION_1_8
+    }
}
```
