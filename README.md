# react-native-navigation-hybrid
A native navigation for React Native.

## 特性

- 使用原生导航组件
- Android 使用了 Lifecycle 架构组件，解决了生命周期问题
- 以 iOS 的导航系统为参照，支持 push, pop, popTo, popToRoot, present, dismiss, replace, replaceToRoot 等操作
- 支持 StatusBar, UINavigationBar(iOS), UITabBar(iOS), ToolBar(Android), BottomNavigationBar(Android) 的全局样式配置以及局部调整
- 支持原生页面和 RN 页面互相跳转和传值
- 支持 vector icons

## Running the Playground Project

To run the playground project, first clone this repo:

```shell
git clone git@github.com:listenzz/react-native-navigation-hybrid.git
cd react-native-navigation-hybrid
```

```shell
npm install
```

```shell
npm start
```

Then, in another CLI window:

To run on iOS: `npm run run:ios`

To run on Android: `npm run run:android`

make sure that you have a  simulator or device when you run andriod

## 版本记录

### 0.1.x

- 支持在现有原生项目基础上嵌入 RN 模块，并使得 RN 的导航栏和原生体验一致，即使是程序员，也无法区分哪些页面是由原生代码编写，哪些页面是由 RN 代码编写
- 支持同一个导航栈内，原生页面和 RN 页面互相跳转、传值、接收返回值
- 支持 push, pop, popTo, popToRoot, replace, replaceToRoot, present, dismiss 等导航操作
- 支持对导航栏以及状态栏的全局样式配置
- 每个页面都可以单独设置导航栏的标题，背景，左右按钮
- 导航栏可以使用 vector fonts 作为按钮图标
- 支持 npm link
 
### 0.2.x
![navigation-android](./screenshot/navigation-android.png)

- 支持 tab, drawer
- 可配置 tabBar 部分属性
- 对 0.1.x 代码作了大量重构，以适应本版本的需求
- 方便接入 redux、mobx 等框架

## 集成到以 RN 为主的项目

你想用 React Native 实现大部分业务，原生代码主要起到搭桥的作用。

> 如果你对原生开发一无所知，建议你使用 [React Navigation](https://reactnavigation.org/docs/intro/)，避免踩一些无能为力的坑。如果你熟悉原生开发，欢迎贡献代码。

请参考下一章节

## 集成到已有原生项目

你的大部分业务已经用原生代码实现，你想添加一些 RN 业务模块。

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

第二和第三种目录结构，在集成上没多大区别。 这里，我们以后者的目录结构来演示如何集成 react-native-navigaton-hybrid 到原生项目。

### 创建 RN 项目并集成 Navigation Hybrid

在和原生应用同级的目录下，使用 `react-native init ReactNativeProject` 命令创建 RN 业务模块。

创建成功后，打开该目录，删除里面的 andriod 和 ios 文件夹，因为我们不会用到它们。

打开 package.json 文件，在里面添加

```json
"dependencies": {
    "react-native-navigation-hybrid": "0.1.24"
}
```

执行 `npm install` 或者 `yarn install`


### RN 项目配置

打开 index.js 这个文件，通常，它就在 package.json 旁边。

你需要注册你的 React 组件

以前，你是这么注册的

```javascript
AppRegistry.registerComponent('ReactNativeProject', () => App);
```

现在，你需要作出改变

```javascript
import { ReactRegistry, Garden } from 'react-native-navigation-hybrid';
import Home from './HomeComponent';
import Profile from './ProfileComponent';

// 配置全局样式
Garden.setStyle({
    topBarStyle: 'dark-content',
});

ReactRegistry.startRegisterComponent();

// 注意，你的每一个页面都需要注册
ReactRegistry.registerComponent('Home', () => Home);
ReactRegistry.registerComponent('Profile', () => Profile);

ReactRegistry.endRegisterComponent();
```

### Android 项目配置

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
+   targetSdkVersion = 27
+   compileSdkVersion = 27
+   buildToolsVersion = '27.0.2'
+   // 必须保证支持包的版本 >= 26.1.0
+   supportLibraryVersion = '27.0.2'
+   // 注意把 ReactNativeProject 替换成你的 RN 项目
+   rn_root = "$rootDir/../ReactNativeProject"
}

buildscript {
    repositories {
        jcenter()
+       google()
    }
    dependencies {
-        classpath 'com.android.tools.build:gradle:2.2.3'
+        classpath 'com.android.tools.build:gradle:3.0.1'
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
   
+   implementation "com.android.support:appcompat-v7:$rootProject.supportLibraryVersion"
+   implementation "com.android.support:support-v4:$rootProject.supportLibraryVersion"
+   implementation "com.android.support:design:$rootProject.supportLibraryVersion"
   
+   implementation project(':react-native-navigation-hybrid')
+   implementation "com.facebook.react:react-native:+" // From node_modules
}
```

在根项目下的 gradle/wrapper/gradle-wrapper.properties 文件中，确保你使用了正确的 gradle wrapper 版本。

```diff
- distributionUrl=https\://services.gradle.org/distributions/gradle-2.14.1-all.zip
+ distributionUrl=https\://services.gradle.org/distributions/gradle-4.1-all.zip
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
        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        bridgeManager.install(getReactNativeHost());
    }
}
```

创建一个 Activity 作为 RN 业务模块的入口：

```java
public class ReactEntryActivity extends ReactAppCompatActivity {
    @Override
    protected String getMainComponentName() {
        return "Home";
    }
}
```

注意，继承的是 ReactAppCompatActivity.

为该 Activity 添加 NoActionBar 主题

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
```

同步构建版本。Navigation Hybrid 使用的构建版本是 27.0.2 ，你的项目可能使用了更高或稍低的版本。你也可能使用了 [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons) 这样的库，它的构建版本是 26.0.1 ，我们需要用脚本把这些库的构建版本统一起来，否则编译项目时可能会出错。

回到 RN 项目的根目录，创建一个叫 scripts 的文件夹，在里面创建一个叫 fix-build-version.js 的文件

```javascript
const fs = require('fs-extra')

// 找到 NavigatonHybrid 的 build.gradle 文件
const navigationHybrid = './node_modules/react-native-navigation-hybrid/android/build.gradle'

// 其它使用了原生源码的库，例如：
// const codePush = './node_modules/react-native-code-push/android/app/build.gradle'
// const vectorIcons = './node_modules/react-native-vector-icons/android/build.gradle'

const gradles = [
  navigationHybrid,
  // codePush,
  // vectorIcons,
]

gradles.forEach(gradle => {
  fs.readFile(gradle, 'utf8', function(err, data) {
    let str = data.replace(/^(\s+compileSdkVersion).*$/gm, '$1 rootProject.ext.compileSdkVersion')
    str = str.replace(/^(\s+buildToolsVersion).*$/gm, '$1 rootProject.ext.buildToolsVersion')
    str = str.replace(/^(\s+targetSdkVersion).*$/gm, '$1 rootProject.ext.targetSdkVersion')
    str = str.replace(/"(com\.android\.support:appcompat-v7:).*"/gm, '"$1$rootProject.ext.supportLibraryVersion"')
    str = str.replace(/"(com\.android\.support:support-v4:).*"/gm, '"$1$rootProject.ext.supportLibraryVersion"')
    str = str.replace(/"(com\.android\.support:design:).*"/gm, '"$1$rootProject.ext.supportLibraryVersion"')
    fs.outputFile(gradle, str)
  })
})

```

现在，让我们激活这个脚本。打开 package.json 文件，作如下修改

```diff
"scripts": {
    "start": "react-native start",
+   "fbv": "node scripts/fix-build-version.js",
+   "postinstall": "npm run fbv"
}
```

执行一次 `npm install` 或 `yarn install`

### iOS 项目配置

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

![ios-run-script](./screenshot/ios-run-script.jpg)

双击标题，将其更名为 Bundle React Native code and images

点击三角图标展开，在其中填入

```
export NODE_BINARY=node
../ReactNativeProject/node_modules/react-native/scripts/react-native-xcode.sh
```

注意将 ReactNativeProject 替换成你的 RN 项目名

![ios-run-script](./screenshot/ios-react-script.png)

像下面那样更改 AppDelegate.m 文件

```objc
#import <NavigationHybrid/NavigationHybrid.h>
#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSURL *jsCodeLocation;
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
    [[HBDReactBridgeManager instance] installWithBundleURL:jsCodeLocation launchOptions:launchOptions];

    self.window.rootViewController = [[HBDNavigationController alloc] initWithRootModule:@"Home" props:nil options:nil];
    [self.window makeKeyAndVisible];
    return YES;
}
@end

```

## 容器

### Stack 

- 导航栈

	我们先要理解一个叫**导航栈**的概念。在 iOS 中，一个导航栈对应一个 `UINavigationController`；在 Android 中，一个导航栈对应一个 `FragmentManager`。

- push

	由 A 页面跳转到 B 页面。
	
	```javascript
    // A.js
    this.props.navigator.push('B')
	```

- pop

	返回到前一个页面。比如你由 A 页面 `push` 到 B 页面，现在想返回到 A 页面。
	
	```javascript
    // B.js
    this.props.navigator.pop()
	```

- popTo

	返回到之前的指定页面。比如你由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回 B 页面。你可以把 B 页面的 `sceneId` 一直传递到 D 页面，然后调用 `popTo('bId')` 返回到 B 页面。
	
	从 B 页面跳转到 C 页面时
	
	```javascript
    // B.js
    this.props.navigator.push('C', {bId: this.props.sceneId})
	```
	
	从 C 页面跳到 D 页面时 
	
	```javascript
    // C.js
    this.props.navigator.push('D', {bId: this.props.bId})
	```
	
	现在想从 D 页面 返回到 B 页面
	
	```javascript
    // D.js
    this.props.navigator.popTo(this.props.bId)
	```
	
- popToRoot

	返回到当前导航栈根页面。比如 A 页面是根页面，你由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回到根部，也就是 A 页面。
	
	```javascript
    // D.js
    this.props.navigator.popToRoot()
	```

- isRoot

	判断一个页面是否根页面，返回值是一个 Promise.
	
	```javascript
    componentWillMount() {
        this.props.navigator.isRoot().then((isRoot) => {
            if(isRoot) {
                this.props.garden.setLeftBarButtonItem({title: '取消', action: 'cancel'});
                this.setState({isRoot});
            }
        })
    }
	``` 

- replace

	用指定页面取代当前页面，比如当前页面是 A，想要替换成 B
	
	```javascript
    // A.js
    this.props.navigator.replace('B')
	```
	
	现在导航栈里没有 A 页面了，被替换成了 B。
	
	> 注意：只能替换位于当前导航栈顶端的页面
	
- replaceToRoot

	把当前导航栈里的所有页面替换成一个页面。譬如 A 页面是根页面，然后 `push` 到 B、C、D 页面，此时导航栈里有 A、B、C、D 四个页面。如果想要重置当前导航栈，把 E 页面设置成根页面。
	
	```javascript
    // D.js
    this.props.navigator.replaceToRoot('E')
	```
	
	现在导航栈里只有 E 页面了。

- present

	present 是一种模态交互模式，类似于 Android 的 `startActivityForResult`，要求后面的页面返回结果给发起 present 的页面。
	
	比如 A 页面 `present` 出 B 页面
	
	```javascript
    // A.js
    this.navigator.present('B', 1)
	```
	
	B 页面返回结果给 A 页面 
	
	```javascript
    // B.js
    this.navigator.setResult(RESULT_OK, {text: 'greeting'})
    this.navigator.dismiss()
	```
	
	A 页面实现 `onComponentResult` 来接收这个结果
	
	```javascript
	// A.js
    onComponentResult(requestCode, resultCode, data) {
        if(requestCode === 1) { 
            if(resultCode === RESULT_OK) {
                this.setState({text: data.text || '', error: undefined});
            } else {
                this.setState({text: undefined, error: 'ACTION CANCEL'});
            }
        }
    }
	```
	
	有些时候，比如选择一张照片，我们先要跳到相册列表页面，然后进入某个相册选择相片返回。这也是没有问题的。
	
	A 页面 `present` 出相册列表页面
	
	```javascript
    //A.js
    this.props.navigator.present('AlbumList', 1)
	```
	
	相册列表页面 `push` 到某个相册
	
	```javascript
    // AlbumList.js
    this.props.navigator.push('Album')
	```
	
	在相册页面选好相片后返回结果给 A 页面
	
	```javascript
    // Album.js
    this.props.navigator.setResult(RESULT_OK, {uri: 'file://...'})
    this.props.navigator.dismiss()
	```
	
	在 A 页面接收返回的结果（略）。
	
	> pop, popTo, popToRoot 也是可以返回结果给目标页面的，但是此时 `requestCode` 的值总是 0 。
	
- dismiss

	关闭 `present` 出来的整个导航栈中的页面，可以在当前导航栈中的任意页面调用。
	
- 传值

	由一个页面跳转到另一个页面时，`push`, `present`, `replace`, `replaceToRoot` 是可以通过 props 这个参数来传值的，但只支持可以序列化成 json 的对象。以下是这些方法的完整签名：
	
	```javascript
    push(moduleName, props={}, options={}, animated = true)
    	
    replace(moduleName, props={}, options={})
    	
    replaceToRoot(moduleName, props={}, options={})
    	
    present(moduleName, requestCode,  props={}, options={}, animated = true)
	```
	
	options 这个参数的作用我们会在其它地方讲解。
	
- 导航栈边界

	比如 A `push` B `push` C `push` D `present` E `push` F
	
	现在存在两个导航栈，A、B、C、D 在一个栈，E 和 F 在另一栈，它们分界就是因为 E 是 D `present` 出来的。
	
	`popTo`, `popToRoot`, `replaceToRoot`, `isRoot` 都是有边界的
	
	在 F 调用 `popTo` 是不能返回 A、B、C、D 中的任何页面的，因为 F 和它们不在同一个栈。
	
	在 F 调用 `popToRoot` 只能返回到 E 页面，因为 E 就是 F 所在栈的根部。
	
	同理，在 F 调用 `replaceToRoot` 只能替换到 E 页面。
	
	在 A 或 E 中调用 `isRoot` 会返回 `true`，其它页面返回 `false`
	

### Tab

- switchToTab
    
    切换到指定 tab
    
- setTabBadge

    设置指定 tab 的 badge

### Drawer

- toggleMenu

    切换抽屉的开关状态
    
- openMenu

    打开抽屉
    
- closeMenu

    关闭抽屉


## 设置样式或主题

一个 APP 中的风格通常是一致的，使用 `Garden.setStyle` 可以全局设置 APP 的主题。

### 设置全局主题

setStyle 接受一个对象为参数，可配置字段如下：

```javascript
{
    screenBackgroundColor: String // 页面背景
    topBarStyle: String // 状态栏和导航栏前景色，可选值有 light-content 和 dark-content
    topBarBackgroundColor: String // 顶部导航栏背景颜色
    statusBarColor: String // 状态栏背景色，仅对 Android 5.0 以上版本生效
    hideBackTitle: Bool // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
    elevation: Number // 导航栏阴影高度， 仅对 Android 5.0 以上版本生效，默认值为 4 dp
    shadowImage: Object // 导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效 
    backIcon: Object // 返回按钮图标，需要传递一个带有 uri 和其它字段的对象
    topBarTintColor: String // 顶部导航栏标题和按钮的颜色
    titleTextColor: String // 顶部导航栏标题颜色
    titleTextSize: Int // 顶部导航栏标题字体大小，默认是 17 dp(pt)
    titleAlignment: String // 顶部导航栏标题的位置，有 left 和 center 两个值可选，默认是 left
    barButtonItemTintColor: String // 顶部导航栏按钮颜色
    barButtonItemTextSize: Int // 顶部导航栏按钮字体大小，默认是 15 dp(pt)
    
    bottomBarBackgroundColor: String // 底部 TabBar 背景颜色
    bottomBarShadowImage: Object // 底部 TabBar 阴影图片，仅对 iOS 和 Android 4.4 以下版本生效 。对 iOS, 只有设置了 bottomBarBackgroundColor 才会生效
    bottomBarButtonItemTintColor: String // 底部 TabBarItem 选中效果
}
```

> 全局设置主题，有些样式需要重新运行原生应用才能看到效果。

- screenBackgroundColor 

    页面背景，仅支持 #RRGGBB 格式的字符串。

- topBarStyle

	可选，导航栏和状态栏前景色，在 iOS 中，默认是白底黑字，在 Android 中，默认是黑底白字。
	
	这个字段一共有两个常量可选： `dark-content` 和 `light-content`，在 Android 6.0 效果如下。
	
	![topbar-default](./screenshot/topbar-default.png)

- topBarBackgroundColor

	可选，导航栏（UINavigationBar | ToolBar）背景颜色。如果不设置，将根据 topBarStyle 来计算，如果 topBarStyle 的值是 dark-content，那么 topBarBackgroundColor 的值是白色，否则是黑色。
	
	> 注意，可配置的颜色仅支持 #AARRGGBB 或者 #RRGGBB 格式的字符

- statusBarColor

	可选，仅对 Android 5.0 以上版本生效。如果不设置，默认取 `topBarBackgroundColor` 的值。
	
	系统启动时，由于还没有设置 statusBarColor，状态栏颜色会出现前后不一致的情况，下图是应用还没启动好时，状态栏可能的颜色。和上面的黑白图对比，是不是有种违和感。
	
	![statusbar-inperfect](./screenshot/statusbar-inperfect.png) 
		
	为了提供一致的用户体验，你可以为 Android 5.0 以上版本配置 `andriod:statusBarColor` 样式。
	
	1.在 res 目录下新建一个名为 values-v21 的文件夹
	
	![statusbar-setup-step-1](./screenshot/statusbar-setup-step-1.png) 
	
	2.在 values-v21 文件夹新建一个名为 styles.xml 的资源文件
	
	![statusbar-setup-step-2](./screenshot/statusbar-setup-step-2.png) 
	
	3.双击打开 values-v21 目录中的 styles.xml 文件，把 App 主题样式 `andriod:statusBarColor` 的值设置成和你用 Garden 设置的一样。

    ```javascript
    import { Garden } from 'react-native-navigation-hybrid'
                	
    Garden.setStyle({
        statusBarColor: '#ffffff'
    })
       
    ```
        
    ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <style name="AppTheme" parent="Theme.AppCompat.Light.NoActionBar">
            <item name="android:statusBarColor">#ffffff</item>
        </style>
    </resources>
    ```
            
    现在，应用启动时和启动完成后的状态栏颜色是一致的了。

- hideBackTitle

	可选，仅对 iOS 生效，用来决定是否隐藏返回按钮旁边的文字，即前一个页面的标题
	
- elevation

	可选，导航栏阴影高度，仅对 Android 5.0 以上版本生效，默认值为 4 dp
	
- shadowImage

	可选，导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效。
	
    ```javascript
    // index.js
    	
    import { Image } from 'react-native'
    import { Garden } from 'react-native-navigation-hybrid'
    	
    Garden.setStyle({
        shadowImage: {
            // color 和 image 二选其一，如果选择 color ，默认生成 1 dp(pt) 高度的纯色图片
            color: '#cccccc', 
            // image: Image.resolveAssetSource(require('./divider.png'))
        },
    })
	
    ```
    
    shadowImage 会有一个默认值，如果你想去掉，可以这样设置 
    
    ```javascript
    Garden.setStyle({
        shadowImage: {},
    })
    ```

- backIcon

	可选，配置返回按钮的图标。如果不配置，则采用平台默认的图标。配置方式如下

    ```javascript
    // index.js
    	
    import { Image } from 'react-native'
    import { Garden } from 'react-native-navigation-hybrid'
    	
    Garden.setStyle({
        backIcon: Image.resolveAssetSource(require('./ic_back.png')),
    })
	
    ```

- topBarTintColor

	可选，顶部导航栏标题和按钮的颜色。如果不设置，将根据 topBarStyle 来计算，如果 topBarStyle 的值是 dark-content，那么 topBarTintColor 的值是黑色，否则是白色。

- titleTextColor

	可选，顶部导航栏标题的颜色。如果不设置，取 topBarTintColor 的值。

- titleTextSize

	可选，顶部导航栏标题的字体大小，默认是 17 dp(pt)。

- titleAlignment

	可选，顶部导航栏标题的位置，仅对 Android 生效，有 left 和 center 两个值可选，默认是 left

- barButtonItemTintColor

	可选，顶部导航栏按钮的颜色。如果不设置， 取 topBarTintColor 的值。

- barButtonItemTextSize

	可选，顶部导航栏按钮的字体大小，默认是 15 dp(pt)

- bottomBarBackgroundColor

    可选，UITabBar(iOS)、BottomNavigationBar(Android) 的背景颜色。
    
- bottomBarShadowImage

    可选，UITabBar(iOS)、BottomNavigationBar(Android) 的阴影图片。仅对 iOS 和 Android 4.4 以下版本生效 ，对 iOS, 只有设置了 bottomBarBackgroundColor 才会生效
    配置方式请参考 `shadowImage`
    
- bottomBarButtonItemTintColor

    可选，底部 TabBarItem 选中效果
    
    
### 静态配置页面

每个页面的标题、按钮，通常是固定的，我们可以通过静态的方式来配置。

我们需要在页面实现 `navigationItem` 这个静态字段，完整的可配置项如下：

```javascript
class Screen extends Component {

    static navigationItem = {
        hideBackButton: true,     // 当前页面是否隐藏返回按钮
        hideShadow: true,         // 当前页面是否隐藏 topBar 阴影
        titleItem: {               // 导航栏标题
            tilte: '这是标题', 
        },
        	
        leftBarButtonItem: {      // 导航栏左侧按钮
            title: '按钮',
            icon: Image.resolveAssetSource(require('./ic_settings.png')),
            insets: {top: -1, left: -8, bottom: 0, right: 0},
            action: 'left-button-click',
            enabled: true,
        },
        	
        rightBarButtonItem: {     // 导航栏右侧按钮
            // 可配置项同 leftBarButtonItem
        },
        
        tabItem: {               // 底部 TabBarItem 可配置项
            title: 'Style',
            icon: { uri: fontUri('FontAwesome', 'leaf', 20) },
            hideTabBarWhenPush: true,
        }
    }
    	
    onBarButtonItemClick(action) {
    	// do something
    }
	
}
```

- hideBackButton

    可选，用来控制是否隐藏当前页面的返回按钮。一旦设置为 true，在 iOS 中将不能通过手势右滑返回，在 Android 中将不能通过返回键（物理）退出当前页面。
	
- hideShadow

    可选，默认是 false。用来控制当前页面是否隐藏 shadowImage 或是把 elevation 的值设置为 0。
	
- titleItem

    可选，设置页面标题

- leftBarButtonItem

    可选，设置导航栏左侧按钮。通常用在根页面，一旦设置了 leftBarButtonItem，将取代返回按钮，在 iOS 中将不能通过手势右滑返回，但在 Andriod 中仍可以通过物理键返回。
	
	title 是按钮标题，icon 是按钮图标，两者设置其一则可，如果同时设置，则只会显示图标。
	
	insets 仅对 iOS 生效，用于调整按钮 icon 或 title 的位置。
	
	action 是个字符串，用来标识用户在当前页面触发的是哪个行为，当用户点击按钮时，这个值会被作为参数传递到实例方法 `onBarButtonItemClick` 。
	
	enabled 是个布尔值，可选，用来标识按钮是否可以点击，默认是 true。

- rightBarButtonItem

	可选，导航栏右侧按钮，可配置项同 leftBarButtonItem，不会对页面有任何副作用。
	
- tabItem 

    可选，设置 UITabBar(iOS)、BottomNavigationBar(Android) 的 tab 标题和 icon。
       
    hideTabBarWhenPush, 当 Stack 嵌套在 Tab 的时候，push 到另一个页面时是否隐藏 TabBar
      
### 动态配置页面

有时，需要根据业务状态来动态改变导航栏中的项目。比如 rightBarButtonItem 是否可以点击，就是个很好的例子。

动态配置页面有两种方式，一种是页面跳转时，由前一个页面决定后一个页面的配置。另一种是当前页面根据应用状态来自行改变。

#### 传值配置

譬如以下是 B 页面的静态配置 

```javascript
// B.js
class B extends Component {
    static navigationItem = {
        titleItem: {               
            tilte: 'B 的标题', 
        },
        rightBarButtonItem: {      
            title: '按钮',
            action: 'left-button-click',
        },
    }
    onBarButtonItemClick(action) {
        // do something
    }
}
```

正常情况下，B 的导航栏标题是 *B 的标题*，导航栏右侧按钮的标题是 *按钮*。

从 A 页面跳转到 B 页面时，我们可以改变 B 页面中的静态设置

```javascript
// A.js
this.props.navigator.push('B', {/*props*/}, {
    titleItem: {
        title: '来自 A 的标题'
    },
    rightBarButtonItem: {
        title: '点我'
    }
})

```

那么，如果 B 页面是从 A 跳过来的，那么 B 的导航栏标题就会变成 *来自 A 的标题* ，导航栏右侧按钮的标题就会变成 *点我*。


#### 动态配置

Garden 提供了一些实例方法，来帮助我们动态改变这些项目。

- setTitleItem

	更改标题
    
    ```javascript
    this.props.garden.setTitleItem({
        title: '新的标题'
    })
    ```

- setLeftBarButtonItem

	更改左侧按钮

- setRightBarButtonItem

	更改右侧按钮
	
    ```javascript
    this.props.garden.setRightBarButtonItem({
        enabled: false
    })
    ```










