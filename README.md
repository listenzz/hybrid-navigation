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

* 使用原生导航组件实现 React Native 页面间的导航，不仅具有更优的性能，而且使得 RN 页面具有原生质感
* 原生页面和 RN 页面共享路由， 使得它们之间相互跳转和传值轻而易举
* 内置 drawer, tabs, stack 标准容器，同时支持自定义容器和导航
* 支持 deep link

## 目录

#### [集成到以 RN 为主的项目](./doc/integration-react.md)

#### [为原生项目添加 RN 模块](./doc/integration-native.md)

#### [容器与导航](./doc/navigation.md)

#### [RN 页面与原生页面相互跳转和传值](./doc/pass-and-return-value.md)

#### [额外的生命周期函数](./doc/lifecycle.md)

#### [设置样式](./doc/style.md)

#### [DeepLink](./doc/deeplink.md)

## 更新日志

最新版本: `0.8.30`

### 0.8.30

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

### 0.8.29

安卓推荐用 HybridReactNativeHost 替代 ReactNativeHost，它为 reload bundle 做了些优化

Navigator 添加 get 和 current 静态方法，帮助我们在注册组件之外获取它们的 navigator

### 0.8.5

Garden#setBottomBarColor 重命名为 Garden#setTabBarColor

navigationItem 配置中 的 `screenColor` 重命名 `screenBackgroundColor`

Garden#setStyle 配置项中：

* `bottomBarColor` 重命名为 `tabBarColor`
* `bottomBarShadowImage` 重命名为 `tabBarShadowImage`
* 用 `tabBarItemColor` 和 `tabBarSelectedItemColor` 取代 `bottomBarButtonItemActiveColor` 和 `bottomBarButtonItemInactiveColor`。`tabBarSelectedItemColor` 和 `bottomBarButtonItemInactiveColor` 的行为是相反的

tabItem 可配置项中， `selectedIcon` 取代了 `inactiveIcon`，并且行为发生了倒置

### 0.8.0

支持自定义容器和导航

Android 支持侧滑返回

TopBar 不再遮挡内容

支持隐藏状态栏
