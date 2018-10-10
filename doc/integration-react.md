# 集成到以 RN 为主的项目

你想用 React Native 实现大部分业务，原生代码主要起到搭桥的作用。

可以参考 [iReading Fork](https://github.com/listenzz/reading) 这个项目。

假设你是通过 `react-native init AwesomeProject` 创建的项目，目录结构是这样的：

```
AwesomeProject/
|—— android/
|—— ios/
|—— node_modules/
|—— package.json
```

## 添加依赖

```
npm install react-native-navigation-hybrid --save
```

## Link

```
$ react-native link react-native-navigation-hybrid
```

## RN 项目配置

打开 index.js 这个文件，通常，它就在 package.json 旁边。

以前，你是这么注册 React 组件

```javascript
AppRegistry.registerComponent('ReactNativeProject', () => App);
```

现在，你需要像下面那样

```javascript
import { ReactRegistry, Garden, Navigator } from 'react-native-navigation-hybrid';
import Home from './HomeComponent';
import Profile from './ProfileComponent';

// 配置全局样式
Garden.setStyle({
  topBarStyle: 'dark-content',
});

// 重要必须
ReactRegistry.startRegisterComponent();

// 注意，你的每一个页面都需要注册
ReactRegistry.registerComponent('Home', () => Home);
ReactRegistry.registerComponent('Profile', () => Profile);

// 重要必须
ReactRegistry.endRegisterComponent();
```

通过 `Navigator#setRoot` 来设置 UI 层级

```javascript
Navigator.setRoot({
  stack: {
    children: [{ screen: { moduleName: 'Navigation' } }],
  },
});
```

具体应用请查看 [Navigator#setRoot](./navigation.md)

### 支持 Redux

想要为每个页面都注入相同的属性，可以利用 `ReactRegistry.startRegisterComponent()` 这个方法，它接受一个函数作为参数，该函数的参数是一个返回我们将要构建的组件的函数，返回值是一个新的组件。

想要支持 Redux，像下面这样配置即可

```jsx
function screenWrapper(screenProvider) {
  const Screen = screenProvider();
  return props => (
    <Provider store={store}>
      <Screen {...props} />
    </Provider>
  );
}

ReactRegistry.startRegisterComponent(screenWrapper);
```

## Android 项目配置

假设你已经配置好了 React 项目

修改 android/build.gradle 文件

```diff
buildscript {
    ext {
        // 为了支持凹凸屏、刘海屏，compileSdkVersion 必须 >= 28
-        buildToolsVersion = "27.0.3"
+        buildToolsVersion = "28.0.1"
        minSdkVersion = 16
-        compileSdkVersion = 27
+        compileSdkVersion = 28
        targetSdkVersion = 26
-        supportLibVersion = "27.1.1"
+        supportLibVersion = "28.0.0"
    }

    dependencies {
-        classpath 'com.android.tools.build:gradle:3.1.1'
+        classpath 'com.android.tools.build:gradle:3.1.4'
    }
}
```

修改 android/app/build.gradle 文件

```diff
dependencies {
-   compile project(':react-native-navigation-hybrid')
+   implementation project(':react-native-navigation-hybrid')
}
```

修改 MainActivity.java 文件

```diff
- import com.facebook.react.ReactActivity;
+ import com.navigationhybrid.ReactAppCompatActivity;

- public class MainActivity extends ReactActivity {
+ public class MainActivity extends ReactAppCompatActivity {
-   @Override
-   protected String getMainComponentName() {
-       return "AwesomeProject";
-   }
}
```

修改 MainApplication.java 文件

```diff
  import com.facebook.react.ReactNativeHost;
+ import com.navigationhybrid.HybridReactNativeHost;
+ import com.navigationhybrid.ReactBridgeManager;


- private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
+ private final ReactNativeHost mReactNativeHost = new HybridReactNativeHost(this) {

}

public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);

+   ReactBridgeManager bridgeManager = ReactBridgeManager.get();
+   bridgeManager.install(getReactNativeHost());
}
```

> 注意：ReactNativeHost 的实例是 HybridReactNativeHost 对象，它为 reload bundle 做了些优化。

### 同步构建版本

查看 [这里](./sync-build-version.md)

## iOS 项目配置

修改 Header Search Paths

![header-search-paths](../screenshot/header-search-paths.jpg)

如图，删掉后面的 NavigationHybrid, 配置成如下的样子：

```bash
$(SRCROOT)/../node_modules/react-native-navigation-hybrid/ios
```

修改 AppDelegate.m 文件

```objc
#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <NavigationHybrid/NavigationHybrid.h>

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *jsCodeLocation;
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
    [[HBDReactBridgeManager sharedInstance] installWithBundleURL:jsCodeLocation launchOptions:launchOptions];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    UIViewController *rootViewController = [UIViewController new];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
```

修改 Info.plist 文件

![controller-base](../screenshot/controller-base.jpg)

## 关于闪屏

<a name="migrate-native"></a>

可以像 playgroud 这个 demo 那样设置闪屏，也可以使用 react-native-splash-screen 设置闪屏
