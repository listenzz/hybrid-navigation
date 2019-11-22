# 为原生项目添加 RN 模块

你的大部分业务已经用原生代码实现，你想添加一些 RN 业务模块。

> RN 和原生混合，可以参考 [hud-hybrid](https://github.com/listenzz/react-native-hud-hybrid)，该项目中的 example 示范了 RN 模块和原生模块的混合布局。

添加 RN 业务模块的原生项目，和通过 `react-native init` 命令创建的项目，它们的目录结构往往是不同的。

通过 `react-native init ReactNativeProject` 创建的项目，目录结构是这样的：

```
ReactNativeProject/
|—— android/
|—— ios/
|—— node_modules/
|—— package.json
```

添加 RN 业务模块的原生项目，目录结构可能是这样的：

```
AndroidProject/
|—— settings.gradle
|—— ReactNativeProject/
|   |—— node_modules/
|   |—— package.json

iOSProject/
|—— Podfile
|—— ReactNativeProject/
|   |—— node_modules/
|   |—— package.json
```

以上，Android 和 iOS 项目使用 git submodule 的方式依赖同一个 RN 项目。

也可能是这样的：

```
AndroidProject/
|—— settings.gradle

iOSProject/
|—— Podfile

ReactNativeProject/
|—— node_modules/
|—— package.json
```

以上，Android 和 iOS 项目使用 gradle 或者 cocopods 依赖本地 RN 项目。

第二和第三种目录结构，在集成上没多大区别。 这里，我们以第三种目录结构来演示如何集成 react-native-navigaton-hybrid 到原生项目。

## 创建 RN 项目并集成 Navigation Hybrid

在和原生应用同级的目录下，使用 `react-native init ReactNativeProject` 命令创建 RN 业务模块。

创建成功后，打开该目录，删除里面的 andriod 和 ios 文件夹，因为我们不会用到它们。

cd 到 ReactNativeProject，执行如下命令添加依赖

```bash
npm install react-native-navigation-hybrid --save
```

## RN 项目配置

打开 index.js 这个文件，通常，它就在 package.json 旁边。

你需要注册你的 React 组件

以前，你是这么注册的

```javascript
AppRegistry.registerComponent('ReactNativeProject', () => App)
```

现在，你需要作出改变

```javascript
import { ReactRegistry, Garden, BarStyleDarkContent } from 'react-native-navigation-hybrid'
import Home from './HomeComponent'
import Profile from './ProfileComponent'

// 配置全局样式
Garden.setStyle({
  topBarStyle: BarStyleDarkContent,
})

ReactRegistry.startRegisterComponent()

// 注意，你的每一个页面都需要注册
ReactRegistry.registerComponent('Home', () => Home)
ReactRegistry.registerComponent('Profile', () => Profile)

ReactRegistry.endRegisterComponent()
```

## Android 项目配置

现在，我们回到 Android 项目，在 settings.gradle 中添加如下配置

```gradle
include ':react-native-navigation-hybrid'
// 注意把 ReactNativeProject 替换成你的 RN 项目
project(':react-native-navigation-hybrid').projectDir = new File(rootProject.projectDir, '../ReactNativeProject/node_modules/react-native-navigation-hybrid/android')
```

在根项目的 build.gradle 文件中，确保以下配置或变更

```diff
ext {
+   minSdkVersion = 16
+   targetSdkVersion = 28
+   compileSdkVersion = 28
+   buildToolsVersion = '28.0.3'
+   supportLibVersion = '28.0.0'
+   // 注意把 ReactNativeProject 替换成你的 RN 项目
+   rn_root = "$rootDir/../ReactNativeProject"
}

buildscript {
    repositories {
+       google()
        jcenter()

    }
    dependencies {
-       classpath 'com.android.tools.build:gradle:2.2.3'
+       classpath 'com.android.tools.build:gradle:3.3.2'
    }
}

allprojects {
    repositories {
        mavenLocal()
        jcenter()
+       google()
+       maven { url "${rn_root}/node_modules/react-native/android" }
    }
}
```

然后，在 app/build.gradle 文件中，作如下变更

```diff
+ project.ext.react = [
+       entryFile                : "index.js",
+       root                     : "$rn_root"
+ ]

+ apply from: "$rn_root/node_modules/react-native/react.gradle"

android {
+   compileSdkVersion rootProject.ext.compileSdkVersion
+   buildToolsVersion rootProject.ext.buildToolsVersion

    defaultConfig {
+       minSdkVersion rootProject.ext.minSdkVersion
+       targetSdkVersion rootProject.ext.targetSdkVersion
    }
}

dependencies {
+   implementation fileTree(include: ['*.jar'], dir: 'libs')

+   implementation "com.android.support:appcompat-v7:$rootProject.supportLibVersion"
+   implementation "com.android.support:support-v4:$rootProject.supportLibVersion"
+   implementation "com.android.support:design:$rootProject.supportLibVersion"

+   implementation project(':react-native-navigation-hybrid')
+   implementation "com.facebook.react:react-native:+" // From node_modules
}
```

在根项目下的 gradle/wrapper/gradle-wrapper.properties 文件中，确保你使用了正确的 gradle wrapper 版本。

```diff
- distributionUrl=https\://services.gradle.org/distributions/gradle-2.14.1-all.zip
+ distributionUrl=https\://services.gradle.org/distributions/gradle-4.10.2-all.zip
```

修改 MainApplication.java 文件。在你的项目中，可能叫其它名字。

```java
public class MainApplication extends Application implements ReactApplication {
    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
        return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
        return Arrays.<ReactPackage>asList(
            new MainReactPackage(),
            new NavigationHybridPackage()
        );
    }

    @Override
    protected String getJSMainModuleName() {
        return "index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    public void onCreate() {
        super.onCreate();
        // react native
        SoLoader.init(this, /* native exopackage */ false);
        ReactBridgeManager bridgeManager = ReactBridgeManager.get();
        bridgeManager.install(getReactNativeHost());
    }
}
```

> 注意：ReactNativeHost 的实例是 HybridReactNativeHost 对象，它为 reload bundle 做了些优化。

创建一个 Activity 继承 ReactAppCompatActivity

重写 `getMainComponentName` 方法

```java
public class ReactEntryActivity extends ReactAppCompatActivity {
    @Override
    protected String getMainComponentName() {
        return "Home";
    }
}
```

或者 `onCreateMainComponent` 方法

```java
@Override
protected void onCreateMainComponent() {
    // 注意不要调用下面这行代码
    // super.onCreateMainComponent();
    ReactBridgeManager bridgeManager = getReactBridgeManager();

    ReactNavigationFragment navigation = new ReactNavigationFragment();
    navigation.setRootFragment(bridgeManager.createFragment("Navigation"));
    ReactNavigationFragment options = new ReactNavigationFragment();
    options.setRootFragment(bridgeManager.createFragment("Options"));

    ReactTabBarFragment tabBarFragment = new ReactTabBarFragment();
    tabBarFragment.setChildFragments(navigation, options);

    setActivityRootFragment(tabBarFragment);
}
```

第一种写法相当于

```java
@Override
protected void onCreateMainComponent() {
    AwesomeFragment home = getReactBridgeManager().createFragment("Home");
    ReactNavigationFragment navigation = new ReactNavigationFragment();
    navigation.setRootFragment(home);

    setActivityRootFragment(navigation);
}
```

为该 Activity 添加 NoActionBar 主题

```xml
<activity
  android:name=".ReactEntryActivity"
  android:theme="@style/Theme.AppCompat.NoActionBar"
/>
```

<a name="sync-build-version"></a>

在 AndroidManifest.xml 中添加如下权限

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
```

## iOS 项目配置

假设你使用 cocopods 来管理依赖

在 Podfile 文件中添加如下设置

```ruby
# 注意把 ReactNativeProject 替换成你的项目
node_modules_path = '../ReactNativeProject/node_modules/'

pod 'React', :path => node_modules_path + 'react-native', :subspecs => [
    'Core',
    'CxxBridge',
    'DevSupport', # Include this to enable In-App Devmenu if RN >= 0.43
    'RCTAnimation',
    'RCTActionSheet',
    'RCTText',
    'RCTImage',
    'RCTSettings',
    'RCTCameraRoll',
    'RCTVibration',
    'RCTNetwork',
    'RCTLinkingIOS',
    'RCTWebSocket', # needed for debugging
]

# Explicitly include Yoga if you are using RN >= 0.42.0
pod 'yoga', :path => node_modules_path +  'react-native/ReactCommon/yoga'
pod 'DoubleConversion', :podspec => node_modules_path + 'react-native/third-party-podspecs/DoubleConversion.podspec'
pod 'GLog', :podspec => node_modules_path + 'react-native/third-party-podspecs/GLog.podspec'
pod 'Folly', :podspec => node_modules_path + 'react-native/third-party-podspecs/Folly.podspec'

pod 'NavigationHybrid', :path => node_modules_path + 'react-native-navigation-hybrid'
```

记得 `pod install` 一次。

找到 Info.plist 文件，右键 -> Open As -> Source Code，添加如下内容

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
```

在 Build Phases 中新建一个 Run Script

![ios-run-script](../screenshot/ios-run-script.jpg)

双击标题，将其更名为 Bundle React Native code and images

点击三角图标展开，在其中填入

```bash
export NODE_BINARY=node ../ReactNativeProject/node_modules/react-native/scripts/react-native-xcode.sh
```

注意将 ReactNativeProject 替换成你的 RN 项目名

![ios-run-script](../screenshot/ios-react-script.png)

像下面那样更改 AppDelegate.m 文件

```objc
#import <NavigationHybrid/NavigationHybrid.h>
#import <React/RCTBundleURLProvider.h>

@interface AppDelegate () <HBDReactBridgeManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSURL *jsCodeLocation;
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
    [[HBDReactBridgeManager sharedInstance] installWithBundleURL:jsCodeLocation launchOptions:launchOptions];
    [HBDReactBridgeManager sharedInstance].delegate = self;

    UIStoryboard *storyboard =  [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager {
    HBDTabBarController *tabs = [[HBDTabBarController alloc] init];
    HBDNavigationController *navigation = [[HBDNavigationController alloc] initWithRootViewController:[manager controllerWithModuleName:@"Navigation" props:nil options:nil]];
    HBDNavigationController *options = [[HBDNavigationController alloc] initWithRootViewController:[manager controllerWithModuleName:@"Options" props:nil options:nil]];

    [tabs setViewControllers:@[ navigation, options ]];
    [manager setRootViewController:tabs];
}

@end
```
