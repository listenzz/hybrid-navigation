# 为原生项目添加 RN 模块

你的大部分业务已经用原生代码实现，你想添加一些 RN 业务模块。

官方文档[Integration with Existing Apps](https://reactnative.dev/docs/0.67/integration-with-existing-apps)，有比较详细的介绍，本文讲述的过程和官方文档大同小异。

为了确保流畅的体验，使用如下目录结构：

```
MyApp
├─ android/
├─ ios/
├─ node_modules/
├─ package.json
```

## 创建 RN 项目

运行如下命令，创建一个 RN 项目：

```sh
npx react-native init <AppName>
```

> 也可以使用 `npx react-native-create-app <AppName>` 命令来创建

创建成功后，打开该目录，**删除里面的 andriod 和 ios 文件夹**。

cd 到 RN 项目，执行如下命令添加依赖：

```sh
yarn add hybrid-navigation
```

## RN 项目配置

打开 index.js 这个文件，通常，它就在 package.json 旁边。

你需要注册你的 React 组件

以前，你是这么注册的

```javascript
AppRegistry.registerComponent('ReactNativeProject', () => App);
```

现在，你需要作出改变

```javascript
import Navigation, { BarStyleDarkContent } from 'hybrid-navigation';
import Home from './HomeComponent';
import Profile from './ProfileComponent';

// 配置全局样式
Navigation.setDefaultOptions({
  topBarStyle: BarStyleDarkContent,
});

Navigation.startRegisterComponent();

// 注意，你的每一个页面都需要注册
Navigation.registerComponent('Home', () => Home);
Navigation.registerComponent('Profile', () => Profile);

Navigation.endRegisterComponent();
```

## Android 项目配置

首先，将现有 Android 项目拷贝到 RN 项目的 android 文件夹下。结构如下：

```
MyApp
├─ android/
│    ├─ app/
│    ├─ build.gradle
│    └─ settings.gradle
├─ ios/
├─ node_modules/
├─ package.json
```

在 settings.gradle 中添加如下配置

```groovy
pluginManagement {
    includeBuild("../node_modules/@react-native/gradle-plugin")
}
plugins {
    id("com.facebook.react.settings")
}
extensions.configure(com.facebook.react.ReactSettingsExtension){ ex ->
    ex.autolinkLibrariesFromCommand()
}
rootProject.name = 'MyApp'
include ':app'
includeBuild('../node_modules/@react-native/gradle-plugin')
```

在根项目的 build.gradle 文件中，确保以下配置或变更

```groovy
buildscript {
    ext {
        buildToolsVersion = "36.0.0"
        minSdkVersion = 24
        compileSdkVersion = 36
        targetSdkVersion = 36
        ndkVersion = "27.1.12297006"
        kotlinVersion = "2.1.20"
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle")
        classpath("com.facebook.react:react-native-gradle-plugin")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin")
    }
}

apply plugin: "com.facebook.react.rootproject"
```

在 app/build.gradle 文件中，作如下变更

```groovy
apply plugin: "com.android.application"
apply plugin: "org.jetbrains.kotlin.android"
apply plugin: "com.facebook.react"

react {
    /* Autolinking */
    autolinkLibrariesWithApp()
}

def enableProguardInReleaseBuilds = false
def jscFlavor = 'io.github.react-native-community:jsc-android:2026004.+'

android {
    ndkVersion rootProject.ext.ndkVersion
    buildToolsVersion rootProject.ext.buildToolsVersion
    compileSdk rootProject.ext.compileSdkVersion

    namespace "com.myapp"

    defaultConfig {
        applicationId "com.myapp"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 1
        versionName "1.0"
    }
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
    }
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
        }
        release {
            signingConfig signingConfigs.debug
            minifyEnabled enableProguardInReleaseBuilds
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
        }
    }
}

dependencies {
    implementation fileTree(dir: "libs", include: ["*.jar"])
    implementation("com.facebook.react:react-android")

    if (hermesEnabled.toBoolean()) {
        implementation("com.facebook.react:hermes-android")
    } else {
        implementation jscFlavor
    }
}
```

在 android/gradle/wrapper/gradle-wrapper.properties 文件中，确保你使用了正确的 gradle wrapper 版本。

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-9.0.0-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

> 注意：Gradle 版本需要与 React Native 版本兼容。对于 React Native 0.73+，建议使用 Gradle 9.0.0。

在 android/gradle.properties 文件中，确保以下配置：

```properties
# AndroidX package structure
android.useAndroidX=true

# Use this property to enable support to the new architecture.
newArchEnabled=true

# Use this property to enable or disable the Hermes JS engine.
hermesEnabled=true

# Use this property to enable edge-to-edge display support.
edgeToEdgeEnabled=true
```

修改 MainApplication.java 文件。在你的项目中，可能叫其它名字。

```java
import android.app.Application;

import androidx.annotation.NonNull;

import com.facebook.common.logging.FLog;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactHost;
import com.facebook.react.ReactNativeApplicationEntryPoint;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.defaults.DefaultReactHost;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.reactnative.hybridnavigation.ReactManager;

import java.util.List;

public class MainApplication extends Application implements ReactApplication {
    private final ReactNativeHost reactNativeHost = new DefaultReactNativeHost(this) {
        @Override
        public List<ReactPackage> getPackages() {
            List<ReactPackage> packages = new PackageList(this).getPackages();
            // Packages that cannot be autolinked yet can be added manually here
            return packages;
        }

        @NonNull
        @Override
        public String getJSMainModuleName() {
            return "index";
        }

        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        public boolean isNewArchEnabled() {
            return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
        }

        @Override
        public boolean isHermesEnabled() {
            return BuildConfig.IS_HERMES_ENABLED;
        }
    };

    @NonNull
    @Override
    public ReactHost getReactHost() {
        return DefaultReactHost.getDefaultReactHost(getApplicationContext(), reactNativeHost, null);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        ReactNativeApplicationEntryPoint.loadReactNative(this);

        ReactManager reactManager = ReactManager.get();
        reactManager.install(getReactHost());

        // register native modules
        reactManager.registerNativeModule("NativeModule", NativeFragment.class);
        FLog.setMinimumLoggingLevel(FLog.INFO);
    }
}
```

创建 `ReactEntryActivity`，继承 `ReactAppCompatActivity`。

> 可以叫其它名字

```java
import com.reactnative.hybridnavigation.ReactAppCompatActivity;

public class ReactEntryActivity extends ReactAppCompatActivity {
    @Override
    protected String getMainComponentName() {
        return "Home";
    }
}
```

如果希望 UI 层级由原生这边决定，则需要实现 `onCreateMainComponent` 方法：

```java
import com.navigation.androidx.StackFragment;
import com.reactnative.hybridnavigation.ReactManager;
import com.reactnative.hybridnavigation.ReactStackFragment;
import com.reactnative.hybridnavigation.ReactTabBarFragment;

@Override
protected void onCreateMainComponent() {
    // 注意不要调用下面这行代码
    // super.onCreateMainComponent();
    ReactManager reactManager = ReactManager.get();

    ReactStackFragment navigation = new ReactStackFragment();
    navigation.setRootFragment(reactManager.createFragment("Navigation", null, null));
    ReactStackFragment options = new ReactStackFragment();
    options.setRootFragment(reactManager.createFragment("Options", null, null));

    ReactTabBarFragment tabBarFragment = new ReactTabBarFragment();
    tabBarFragment.setChildFragments(navigation, options);

    setActivityRootFragment(tabBarFragment);
}
```

为 `ReactEntryActivity` 添加 NoActionBar 主题

```xml
<activity
  android:name=".ReactEntryActivity"
  android:theme="@style/Theme.AppCompat.NoActionBar"
/>
```

在 AndroidManifest.xml 中添加如下权限

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>

<application
    android:usesCleartextTraffic="true"
    tools:targetApi="28"
    tools:ignore="GoogleAppIndexingWarning">
    <activity android:name="com.facebook.react.devsupport.DevSettingsActivity" />
</application>
```

## iOS 项目配置

首先，将现有 iOS 项目拷贝到 RN 项目的 ios 文件夹下。结构如下：

```
MyApp
├─ android/
├─ ios/
│   ├─ Podfile
│   ├─ *.xcodeproj/
│   └─ *.xcworkspace/
├─ node_modules/
├─ package.json
```

假设你使用 CocoaPods 来管理依赖，在 Podfile 文件中添加如下设置

```ruby
# Disable New Architecture (optional)
# ENV['RCT_NEW_ARCH_ENABLED'] = '0'

# Resolve react_native_pods.rb with node to allow for hoisting
require Pod::Executable.execute_command('node', ['-p',
    'require.resolve(
        "react-native/scripts/react_native_pods.rb",
        {paths: [process.argv[1]]},
    )', __dir__]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
    Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
    use_frameworks! :linkage => linkage.to_sym
end

target 'MyApp' do
    config = use_native_modules!
    use_react_native!(
        :path => config[:reactNativePath],
        :hermes_enabled => true,
        :app_path => "#{Pod::Config.instance.installation_root}/.."
    )

    post_install do |installer|
        react_native_post_install(
            installer,
            config[:reactNativePath],
            :mac_catalyst_enabled => false
        )
    end
end
```

记得 `pod install` 一次。

找到 Info.plist 文件，右键 -> Open As -> Source Code，添加如下内容

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
<key>RCTNewArchEnabled</key>
<true/>
```

> 注意：`NSAllowsArbitraryLoads` 设置为 `true` 仅用于开发环境，生产环境应该移除或设置为 `false`。`RCTNewArchEnabled` 用于启用新的 React Native 架构（Fabric 和 TurboModules）。

像下面那样更改 AppDelegate.h 文件

```objc
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
```

像下面那样更改 AppDelegate.m 文件

```objc
#import "AppDelegate.h"

#import <React-RCTAppDelegate/RCTDefaultReactNativeFactoryDelegate.h>
#import <React-RCTAppDelegate/RCTReactNativeFactory.h>
#import <ReactAppDependencyProvider/RCTAppDependencyProvider.h>

#import <React/RCTLinkingManager.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLog.h>
#import <React/RCTDevMenu.h>

#import <HybridNavigation/HybridNavigation.h>
#import "NativeViewController.h"

@interface ReactNativeDelegate : RCTDefaultReactNativeFactoryDelegate
@end

@implementation ReactNativeDelegate

- (NSURL *)bundleURL {
#if DEBUG
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
    return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end

@interface AppDelegate () <HBDReactBridgeManagerDelegate>

@property (strong, nonatomic) RCTRootViewFactory *rootViewFactory;
@property (strong, nonatomic) id<RCTReactNativeFactoryDelegate> reactNativeDelegate;
@property (strong, nonatomic) RCTReactNativeFactory *reactNativeFactory;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RCTSetLogThreshold(RCTLogLevelInfo);

    ReactNativeDelegate *delegate = [[ReactNativeDelegate alloc] init];
    RCTReactNativeFactory *factory = [[RCTReactNativeFactory alloc] initWithDelegate:delegate];
    delegate.dependencyProvider = [[RCTAppDependencyProvider alloc] init];

    self.reactNativeDelegate = delegate;
    self.reactNativeFactory = factory;
    self.rootViewFactory = factory.rootViewFactory;

    [self.rootViewFactory initializeReactHostWithLaunchOptions:launchOptions devMenuConfiguration:[RCTDevMenuConfiguration defaultConfiguration]];
    [[HBDReactBridgeManager get] installWithReactHost:self.rootViewFactory.reactHost];

    // register native modules
    [[HBDReactBridgeManager get] registerNativeModule:@"NativeModule" forViewController:[NativeViewController class]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager {
    // 如果需要由原生决定 UI 层级，可以在这里设置
    // HBDTabBarController *tabs = [[HBDTabBarController alloc] init];
    // HBDNavigationController *navigation = [[HBDNavigationController alloc] initWithRootViewController:[manager viewControllerWithModuleName:@"Navigation" props:nil options:nil]];
    // HBDNavigationController *options = [[HBDNavigationController alloc] initWithRootViewController:[manager viewControllerWithModuleName:@"Options" props:nil options:nil]];
    // [tabs setViewControllers:@[ navigation, options ]];
    // [manager setRootViewController:tabs];
}

// iOS 9.x or newer
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [RCTLinkingManager application:application openURL:url options:options];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [GlobalStyle globalStyle].interfaceOrientation;
}

@end
```
