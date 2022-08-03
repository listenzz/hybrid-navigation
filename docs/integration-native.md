# 为原生项目添加 RN 模块

你的大部分业务已经用原生代码实现，你想添加一些 RN 业务模块。

官方文档[Integration with Existing Apps](https://reactnative.dev/docs/0.67/integration-with-existing-apps)，有比较详细的介绍，本文讲述的过程和官方文档大同小异。

为了确保流畅的体验，使用如下目录结构：

```
MyApp
|-- android/
|-- ios/
|-- node_modules/
|-- package.json
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
AppRegistry.registerComponent('ReactNativeProject', () => App)
```

现在，你需要作出改变

```javascript
import { ReactRegistry, Garden, BarStyleDarkContent } from 'hybrid-navigation'
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

首先，将现有 Android 项目拷贝到 RN 项目的 android 文件夹下。结构如下：

```
MyApp
|-- android/
|-- -- app/
|-- -- build.gradle
|-- -- settings.gradle
|-- ios/
|-- node_modules/
|-- package.json
```

在 settings.gradle 中添加如下配置

```groovy
rootProject.name = 'MyApp'
apply from: file("../node_modules/@react-native-community/cli-platform-android/native_modules.gradle")
applyNativeModulesSettingsGradle(settings)
include ':app'
```

在根项目的 build.gradle 文件中，确保以下配置或变更

```diff
  ext {
+     minSdkVersion = 21
+     targetSdkVersion = 30
+     compileSdkVersion = 30
+     buildToolsVersion = '30.0.2'
  }

  buildscript {
      repositories {
+         google()
+         mavenCentral()
      }
      dependencies {
-         classpath 'com.android.tools.build:gradle:2.2.3'
+         classpath 'com.android.tools.build:gradle:4.2.2'
      }
  }

  allprojects {
      repositories {
+         maven {
+             // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
+             url("$rootDir/../node_modules/react-native/android")
+         }
+         maven {
+             // Android JSC is installed from npm
+             url("$rootDir/../node_modules/jsc-android/dist")
+         }
+         mavenCentral {
+             // We don't want to fetch react-native from Maven Central as there are
+             // older versions over there.
+             content {
+                 excludeGroup "com.facebook.react"
+             }
+         }
+         google()
+         maven { url 'https://www.jitpack.io' }
      }
  }
```

在 app/build.gradle 文件中，作如下变更

```diff
+ project.ext.react = [
+     entryFile: "index.js",
+     enableHermes: false,
+ ]

+ apply from: "../../node_modules/react-native/react.gradle"

+ def jscFlavor = 'org.webkit:android-jsc:+'
+ def enableHermes = project.ext.react.get("enableHermes", false);

  android {
+     compileSdkVersion rootProject.ext.compileSdkVersion
+     buildToolsVersion rootProject.ext.buildToolsVersion

      defaultConfig {
+         minSdkVersion rootProject.ext.minSdkVersion
+         targetSdkVersion rootProject.ext.targetSdkVersion
      }
  }

  dependencies {
+     implementation fileTree(include: ['*.jar'], dir: 'libs')

+     implementation project(':hybrid-navigation')
+     implementation "com.facebook.react:react-native:+" // From node_modules
+     implementation "androidx.swiperefreshlayout:swiperefreshlayout:1.1.0"
+     if (enableHermes) {
+		  def hermesPath = "../../node_modules/hermes-engine/android/";
+		  debugImplementation files(hermesPath + "hermes-debug.aar")
+		  releaseImplementation files(hermesPath + "hermes-release.aar")
+	  } else {
+		  implementation jscFlavor
+	  }
  }
+ apply from: file("../../node_modules/@react-native-community/cli-platform-android/native_modules.gradle")
+ applyNativeModulesAppBuildGradle(project)
```

在 android/gradle/wrapper/gradle-wrapper.properties 文件中，确保你使用了正确的 gradle wrapper 版本。

```diff
- distributionUrl=https\://services.gradle.org/distributions/gradle-2.14.1-all.zip
+ distributionUrl=https\://services.gradle.org/distributions/gradle-7.2-all.zip
```

修改 MainApplication.java 文件。在你的项目中，可能叫其它名字。

```java
public class MainApplication extends Application implements ReactApplication {

	private final ReactNativeHost mReactNativeHost =
		new ReactNativeHost(this) {
			@Override
			public boolean getUseDeveloperSupport() {
				return BuildConfig.DEBUG;
			}

			@Override
			protected List<ReactPackage> getPackages() {
				@SuppressWarnings("UnnecessaryLocalVariable")
				List<ReactPackage> packages = new PackageList(this).getPackages();
				return packages;
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

	@Override
	public void onCreate() {
		super.onCreate();
		SoLoader.init(this, /* native exopackage */ false);
		ReactBridgeManager bridgeManager = ReactBridgeManager.get();
		bridgeManager.install(getReactNativeHost());
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
@Override
protected void onCreateMainComponent() {
    // 注意不要调用下面这行代码
    // super.onCreateMainComponent();
    ReactBridgeManager bridgeManager = getReactBridgeManager();

    ReactStackFragment navigation = new ReactStackFragment();
    navigation.setRootFragment(bridgeManager.createFragment("Navigation"));
    ReactStackFragment options = new ReactStackFragment();
    options.setRootFragment(bridgeManager.createFragment("Options"));

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
|-- android/
|-- ios/
|-- -- Podfile
|-- -- *.xcodeproj/
|-- -- *.xcworkspace/
|-- node_modules/
|-- package.json
```

假设你使用 cocopods 来管理依赖，在 Podfile 文件中添加如下设置

```ruby
platform :ios, '11.0'
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

target 'MyApp' do
    config = use_native_modules!
    use_react_native!(
      :path => config[:reactNativePath],
      # to enable hermes on iOS, change `false` to `true` and then install pods
      :hermes_enabled => false
    )
end

post_install do |installer|
    react_native_post_install(installer)
    __apply_Xcode_12_5_M1_post_install_workaround(installer)
end
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

![integration-native-2021-10-19-15-38-04](https://todoit.oss-cn-shanghai.aliyuncs.com/todoit/integration-native-2021-10-19-15-38-04.jpg)

双击标题，将其更名为 Bundle React Native code and images

点击三角图标展开，在其中填入

```bash
export NODE_BINARY=node ../node_modules/react-native/scripts/react-native-xcode.sh
```

像下面那样更改 AppDelegate.h 文件

```objc
#import <UIKit/UIKit.h>
#import <React/RCTBridgeDelegate.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCTBridgeDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
```

像下面那样更改 AppDelegate.m 文件

```objc
#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridgeModule.h>
#import <HybridNavigation/HybridNavigation.h>

@interface AppDelegate () <HBDReactBridgeManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
    [[HBDReactBridgeManager get] installWithBridge:bridge];

    UIStoryboard *storyboard =  [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
    return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
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
