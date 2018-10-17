# react-native-navigation-hybrid

Seamless navigation between native and React Native.

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
```

```shell
npm start
```

Then, in another CLI window:

```shell
npm run run:android
```

[**Download demo apk**](https://raw.githubusercontent.com/listenzz/react-native-navigation-hybrid/master/screenshot/app-release.apk)

### run on iOS

First, make sure that you have install [cocoapods](https://guides.cocoapods.org/).

Then,

```shell
cd playground/ios

pod install

cd ../../
```

Then,

```shell
npm install
```

```shell
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

最新版本: `0.9.5`

### 0.9.1 - 2018/10/14

navigationItem 添加 `navigationBarColorAndroid` 可配置项，用于修改虚拟键的背景颜色，对 Andriod 26 以上版本生效。默认规则如下：

- 含「底部 Tab」的页面，虚拟键设置为「底部 Tab」的颜色

- 不含「底部 Tab」的页面，默认使用页面背景颜色，也就是 `screenBackgroundColor`

- modal 默认是透明色

某些页面，比如从底部往上滑的 modal, 需要开发者使用 `navigationBarColorAndroid` 自行适配，请参考 playground/src/ReactModal.js 这个文件

### 0.9.0 - 2018/10/7

- react-native 升级到 0.57.1，不再兼容低于 0.57.1 的版本，请参考官方文档进行 react-native 的升级

- 为了支持凹凸屏、刘海屏，Android 构建版本更新到 28，请查看 [集成到以 RN 为主的项目](./doc/integration-react.md) 和 [为原生项目添加 RN 模块](./doc/integration-native.md) 以及 [同步构建版本](./doc/sync-build-version.md) 以获得最新的指引。

- 布局描述对象改变，也就是 `Navigator#setRoot` 接受的第一个参数格式发生变化，现在如何正确地传递布局对象，请查看 [容器与导航](./doc/navigation.md)

- `routeGraph` 从 `router` 移动到 `Navigator`, 返回的数据结构也发生了变化，以更好地描述 UI 层级，详情请查看 [容器与导航](./doc/navigation.md)

- `currentRoute` 从 `router` 移动到 `Navigator`

- 移除了所有已经弃用的 API

### 0.8.31 - 2018/9/26

#### iOS

```objc
// HBDNavigator.h
- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc;
```

方法签名变更为

```objc
// HBDNavigator.h
- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc;
```

#### Android

```java
// Navigator.java
boolean primaryChildFragment(AwesomeFragment fragment, ArrayList<Bundle> graph, ArrayList<Bundle> modalContainer);
```

方法签名更改为：

```java
// Navigator.java
boolean primaryFragment(AwesomeFragment fragment, ArrayList<Bundle> root, ArrayList<Bundle> modal);
```

### 0.8.30 - 2018/9/26

#### iOS

```objc
// HBDNavigator.h
- (BOOL)buildRouteGraphWithController:(UIViewController *)vc graph:(NSMutableArray *)container;
```

方法签名变更为

```objc
// HBDNavigator.h
- (BOOL)buildRouteGraphWithController:(UIViewController *)vc root:(NSMutableArray *)root;
```

`HBDReactBridgeManager` 中移除了 `isReactModuleInRegistry` 方法，添加了 `reactModuleRegisterCompleted` 属性

#### Android

```java
// Navigator.java
boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> graph, ArrayList<Bundle> modalContainer);
```

方法签名更改为：

```java
// Navigator.java
boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> root, ArrayList<Bundle> modal);
```

`ReactBrideManager` 中 `instance` 静态变量不再公开，提供 `get` 方法来获取单例实例

`ReactModuleRegistryListener` 重构为 `ReactModuleRegisterListener`

移除了 `ReactBrideManager` 中的 `isReactModuleInRegistry` 变量以及相关方法，添加了 `reactModuleRegisterCompleted` 变量及相关方法

### 0.8.29 - 2018/9/21

安卓推荐用 HybridReactNativeHost 替代 ReactNativeHost，它为 reload bundle 做了些优化

Navigator 添加 get 和 current 静态方法，帮助我们随时随地获取我们想要的 navigator.
