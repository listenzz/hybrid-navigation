# hybrid-navigation

React Native Navigation that supports seamless navigation between Native and React.

## 特性

- 使用原生导航组件实现 React Native 页面间的导航，不仅具有更优的性能，而且使得 RN 页面具有原生质感
- 原生页面和 RN 页面共享路由， 使得它们之间相互跳转和传值轻而易举
- 内置 drawer, tabs, stack 标准容器，同时支持自定义容器和导航
- 支持 deep link

![navigation-android](./screenshot/android.png)

## Running the example project

To run the example project, first clone this repo:

```shell
git clone git@github.com:listenzz/hybrid-navigation.git
cd hybrid-navigation
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

[**Download demo apk**](https://raw.githubusercontent.com/listenzz/hybrid-navigation/master/screenshot/app-release.apk)

或通过扫描二维码安装 demo

![demo-qrcode](./screenshot/demo-qrcode.png)

### run on iOS

First,

```shell
npm install
# &
cd ios && pod install
# &
npm start
```

Then, in another CLI window:

```shell
npm run run:ios
```

## 目录

#### [集成到以 RN 为主的项目](./doc/integration-react.md)

#### [为原生项目添加 RN 模块](./doc/integration-native.md)

#### [容器与导航](./doc/navigation.md)

#### [RN 页面与原生页面相互跳转和传值](./doc/pass-and-return-value.md)

#### [Hooks](./doc/lifecycle.md)

#### [设置样式](./doc/style.md)

#### [DeepLink](./doc/deeplink.md)
