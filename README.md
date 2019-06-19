# react-native-navigation-hybrid

Native navigation library for ReactNative, supporting navigating between native and ReactNative seamlessly.

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

最新版本: `0.13.6` - 2019/06/18

### 0.14.0 - 2019/06/20

- 自定义 TabBar 传递的数据发生变化，详见 [自定义 TabBar 文档](./doc/custom-tabbar.md)

- 优化和 `Garden` 相关的若干 api，详见 [style 文档](./doc/style.md)

### 0.13.6 - 2019/06/18

- 修复和 react-native-code-push 协作偶尔导致的崩溃

### 0.13.0 - 2019/05/11

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
