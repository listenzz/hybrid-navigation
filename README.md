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
cd ios && pod install
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

#### [Hooks](./doc/lifecycle.md)

#### [设置样式](./doc/style.md)

#### [DeepLink](./doc/deeplink.md)

## 最近更新日志

| React Native version(s) | Supporting Navigation version(s) | 发布日期   |
| ----------------------- | -------------------------------- | ---------- |
| >= 0.60                 | 0.23.3                           | 2020/06/08 |
| < 0.60                  | 0.16.14                          | 2019/12/20 |

### 0.23.x

- support deep link with query string

### 0.22.x

- 适配 RN 0.62

- 改变了 `present`, `showModal` 的方法签名

- 重新添加 `useVisibleEffect` 钩子，移除了 `useVisibility`

  ```js
  import React, { useCallback } from 'react'
  import { useVisibleEffect } from 'react-native-navigation-hybrid'

  function Lifecycle({ sceneId }) {
    const visibleCallback = useCallback(() => {
      console.info(`Page is visible [${sceneId}]`)
      return () => {
        console.info(`Page is gone [${sceneId}]`)
      }
    }, [sceneId])

    useVisibleEffect(sceneId, visibleCallback)
  }
  ```

- 添加 `useVisible` 钩子 (0.22.1)

  ```js
  import React, { useEffect } from 'react'
  import { useVisible } from 'react-native-navigation-hybrid'

  function Lifecycle({ sceneId }) {
    const visible = useVisible(sceneId)

    useEffect(() => {
      if (visible) {
        console.info(`Page is visible [${sceneId}]`)
      } else {
        console.info(`Page is invisible [${sceneId}]`)
      }
    }, [visible, sceneId])
  }
  ```

### 0.21.x

- 移除了额外的 `componentDidAppear` 和 `componentDidDisappear` 生命周期函数，移除了 `useVisibleEffect` 钩子函数

  现在使用 `useVisibility` 钩子来达到同样的目的

  ```js
  import React, { useState, useEffect } from 'react'
  import { useVisibility } from 'react-native-navigation-hybrid'

  function Lifecycle({ sceneId }) {
    useVisibility(sceneId, (visible) => {
      if (visible) {
        console.info(`Page is visible [${sceneId}]`)
      } else {
        console.info(`Page is gone [${sceneId}]`)
      }
    })
  }
  ```

- 移除了额外的 `onBackPressed` 生命周期函数和 `useBackEffect` 钩子函数

  现在使用 `BackHandler` 或 `useBackHandler` 来处理 Android 平台的 modal 的返回事件

  ```js
  import { BackHandler } from 'react-native'
  // or
  import { useBackHandler } from '@react-native-community/hooks'
  ```

- 移除了额外的 `onComponentResult` 生命周期函数

  现在使用 `useResult` 这个钩子函数来实现同样的功能

- 移除了额外的 `onBarButtonItemClick` 生命周期函数

### 0.20.x

- 移除了 `replace` `replaceToRoot`

- 添加 `redirectTo` 以取代 `replace`

### 0.19.x

- `pop` `popTo` `popToRoot` `dismiss` `hideModal` `switchTab` 现在返回一个 Promise

### 0.18.x

- 破坏性更新：`TabBar` 和 `navigationBarColorAndroid` 的 API 略有变更。

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
