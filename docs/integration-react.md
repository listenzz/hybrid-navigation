# 集成到以 RN 为主的项目

> 本文档仅适用于 RN0.60 以上版本

你想用 React Native 实现大部分业务，原生代码主要起到搭桥的作用。

假设你是通过 `react-native init MyApp` 创建的项目，目录结构是这样的：

```
MyApp/
├─ android/
├─ ios/
├─ node_modules/
├─ package.json
```

## 添加依赖

```sh
npm install hybrid-navigation --save
# or
yarn add hybrid-navigation
```

## RN 项目配置

打开 index.js 这个文件，通常，它就在 package.json 旁边。

以前，你是这么注册 React 组件

```js
import { AppRegistry } from 'react-native'
import App from './App'
import { name as appName } from './app.json'

AppRegistry.registerComponent(appName, () => App)
```

现在，你需要像下面那样

```js
import { ReactRegistry, Garden, Navigator, BarStyleDarkContent } from 'hybrid-navigation'
import App from './App'

// 配置全局样式
Garden.setStyle({
  topBarStyle: BarStyleDarkContent,
})

// 重要必须
ReactRegistry.startRegisterComponent()

// 注意，你的每一个页面都需要注册
ReactRegistry.registerComponent('App', () => App)

// 重要必须
ReactRegistry.endRegisterComponent()

// 通过 `Navigator#setRoot` 来设置 UI 层级
Navigator.setRoot({
  stack: {
    children: [{ screen: { moduleName: 'App' } }],
  },
})
```

`setRoot` 具体用法请查看 [Navigator#setRoot](./navigation.md)

另外有一个需要注意的地方，hybrid-navigation 接管了状态栏，如果代码里面有使用 `<StatusBar />` 组件，需要移除。

```diff
-  <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
```

### 支持 Redux

想要为每个页面都注入相同的属性，可以利用 `ReactRegistry.startRegisterComponent()` 这个方法，它接受一个 [HOC](https://reactjs.org/docs/higher-order-components.html) 作为参数。

想要支持 Redux，像下面这样配置即可

```jsx
function withRedux(WrappedComponent) {
  return class ReduxProvider extends React.Component {
    // 注意复制 navigationItem
    static navigationItem = (WrappedComponent as any).navigationItem
    static displayName = `withRedux(${WrappedComponent.displayName})`

    render() {
      return (
        <Provider store={store}>
          {/* 注意传递 props 属性 */}
          <WrappedComponent {...this.props} />
        </Provider>
      )
    }
  }
}

ReactRegistry.startRegisterComponent(withRedux)
```

其中 `withRedux` 就是一个 [HOC](https://reactjs.org/docs/higher-order-components.html)

## Android 项目配置

修改 MainActivity.java 文件

```diff
- import com.facebook.react.ReactActivity;
+ import com.reactnative.hybridnavigation.ReactAppCompatActivity;

- public class MainActivity extends ReactActivity {
+ public class MainActivity extends ReactAppCompatActivity {
-     @Override
-     protected String getMainComponentName() {
-        return "MyApp";
-     }
  }
```

修改后一般长下面这个样子：

```java
package com.myapp69;

import com.reactnative.hybridnavigation.ReactAppCompatActivity;

public class MainActivity extends ReactAppCompatActivity {

}
```

修改 MainApplication.java 文件

```diff
  import com.facebook.react.ReactNativeHost;
+ import com.reactnative.hybridnavigation.ReactBridgeManager;

  public void onCreate() {
      super.onCreate();
      SoLoader.init(this, /* native exopackage */ false);

+     ReactBridgeManager bridgeManager = ReactBridgeManager.get();
+     bridgeManager.install(getReactNativeHost());
  }
```

如果你的 RN 版本 >=0.60 && < 0.62，修改 android/app/build.gradle 文件，添加依赖

```diff
  implementation "com.facebook.react:react-native:+"  // From node_modules
+ implementation "androidx.swiperefreshlayout:swiperefreshlayout:1.0.0"
```

运行项目，如果发现 TopBar 的高度不正常，记得移除所有 `<StatusBar />` 组件

## iOS 项目配置

更新 pod 依赖

```sh
cd ios & pod install
```

修改 AppDelegate.m 文件

```diff
  #import <React/RCTBridge.h>
  #import <React/RCTBundleURLProvider.h>
- #import <React/RCTRootView.h>
+ #import <HybridNavigation/HybridNavigation.h>

  @implementation AppDelegate

  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  {
-    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
-                                                   moduleName:@"RN60"
-                                            initialProperties:nil];
-
-    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

+    [[HBDReactBridgeManager get] installWithBridge:bridge];
+
     self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
+    self.window.windowLevel = UIWindowLevelStatusBar + 1;
     UIViewController *rootViewController = [UIViewController new];
-    rootViewController.view = rootView;
+    rootViewController.view.backgroundColor = UIColor.whiteColor;
     self.window.rootViewController = rootViewController;
     [self.window makeKeyAndVisible];
     return YES;
 }

 @end
```

修改 Info.plist 文件

![integration-react-2021-10-19-15-38-49](https://todoit.oss-cn-shanghai.aliyuncs.com/todoit/integration-react-2021-10-19-15-38-49.jpg)

运行项目，如果出现关于状态栏的错误提示，记得移除所有 `<StatusBar />` 组件。

## 关于闪屏

请参考[如何在 React Native 中设置闪屏](https://todoit.tech/splash-screen.html)一文。

## 参考

[一行命令创建 RN 项目并集成本库](https://github.com/listenzz/react-native-create-app)
