# hybrid-navigation

React Native Navigation that supports seamless navigation between Native and React.

## 特性

-   使用原生导航组件实现 React Native 页面间的导航，不仅具有更优的性能，而且使得 RN 页面具有原生质感
-   原生页面和 RN 页面共享路由， 使得它们之间相互跳转和传值轻而易举
-   内置 drawer, tabs, stack 标准容器，同时支持自定义容器和导航
-   支持 Deep Link

![navigation-android](./screenshot/android.png)

## 版本兼容

| 版本 | RN 版本 | RN 架构 |
| ---- | ------- | ------- |
| 2.x  | < 0.82  | 旧架构  |
| 3.x  | >= 0.83 | 新架构  |

## 运行 example 项目

首先 clone 本项目

```shell
git clone git@github.com:listenzz/hybrid-navigation.git
cd hybrid-navigation
```

然后在项目根目录下运行如下命令：

```shell
yarn install
# &
yarn start
```

### 在 Android 上运行

首先，确保你有一个模拟器或设备

如果熟悉原生开发，使用 Android Studio 打开 android 目录，像运行原生应用那样运行它。

注意修改 Gradle JDK 版本为 17，否则会报错。

```error
Cause: error=2, No such file or directory
```

也可以使用命令行：

```sh
# 在项目根目录下运行
yarn android
```

你可能需要运行如下命令，才可以使用 Hot Reload 功能

```sh
adb reverse tcp:8081 tcp:8081
```

[**Download demo apk**](https://todoit.oss-cn-shanghai.aliyuncs.com/app-release.apk)

或通过扫描二维码安装 demo

![README-2021-10-19-15-58-19](https://todoit.oss-cn-shanghai.aliyuncs.com/todoit/README-2021-10-19-15-58-19.png)

### 在 iOS 上运行

首先安装 cocoapods 依赖，在项目根目录下运行如下命令：

```sh
cd ios && pod install
# 成功安装依赖后，回到根目录
cd -
```

如果熟悉原生开发，使用 Xcode 打开 ios 目录，像运行原生应用那样运行它，或者使用命令行：

```sh
# 在项目根目录下运行
yarn ios
```

## 文档

[从这里开始](https://todoit.tech/rn/hybrid-navigation/)
