# 样式和主题

一个 APP 中的风格通常是一致的，使用 `Garden.setStyle` 可以全局设置 APP 的主题。

我们提供了三种设置图片的方式

1.  加载静态图片

```javascript
import { Image } from 'react-native';

icon: Image.resolveAssetSource(require('./images/ic_settings.png')),
```

2.  加载原生图片

```javascript
import { PixelRatio } from 'react-native';

icon: { uri: 'flower', scale: PixelRatio.get() },
```

3.  加载网络图片（不推荐）

```javascript
icon: {
  uri: 'http://xxx.xx/?width=24&height=24&scale=3';
}
```

会占用主线程，导致卡顿，并且没有缓存

4.  使用 icon font

```javascript
icon: { uri: fontUri('FontAwesome', 'navicon', 24)},
```

如果项目中使用了 react-native-vector-icons 这样的库，请参考 playground 中 Options.js 这个文件

## 设置全局主题

setStyle 接受一个对象为参数，可配置字段如下：

```javascript
{
  screenBackgroundColor: String; // 页面背景
  topBarStyle: String; // 状态栏和导航栏前景色，可选值有 light-content 和 dark-content
  topBarColor: String; // 顶部导航栏背景颜色
  statusBarColor: String; // 状态栏背景色，仅对 Android 5.0 以上版本生效
  hideBackTitle: Bool; // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
  elevation: Number; // 导航栏阴影高度， 仅对 Android 5.0 以上版本生效，默认值为 4 dp
  shadowImage: Object; // 导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效
  backIcon: Object; // 返回按钮图标，需要传递一个带有 uri 和其它字段的对象
  topBarTintColor: String; // 顶部导航栏按钮的颜色
  titleTextColor: String; // 顶部导航栏标题颜色
  titleTextSize: Int; // 顶部导航栏标题字体大小，默认是 17 dp(pt)
  titleAlignment: String; // 顶部导航栏标题的位置，有 left 和 center 两个值可选，默认是 left
  barButtonItemTextSize: Int; // 顶部导航栏按钮字体大小，默认是 15 dp(pt)
  swipeBackEnabledAndroid: Bool; // Android 是否开启右滑返回，默认是 false

  tabBarColor: String; // 底部 TabBar 背景颜色
  tabBarShadowImage: Object; // 底部 TabBar 阴影图片，仅对 iOS 和 Android 4.4 以下版本生效 。对 iOS, 只有设置了 tabBarColor 才会生效
  tabBarItemColor: String; // 当 `tabBarSelectedItemColor` 未设置时，此值为选中效果，否则为未选中效果
  tabBarSelectedItemColor: String; // 底部 TabBarItem icon 选中效果
  badgeColor: Stringg; // Badge 以及小红点的颜色
}
```

> 全局设置主题，有些样式需要重新运行原生应用才能看到效果。

* screenBackgroundColor

页面背景，仅支持 #RRGGBB 格式的字符串。

* topBarStyle

可选，导航栏和状态栏前景色，在 iOS 中，默认是白底黑字，在 Android 中，默认是黑底白字。

这个字段一共有两个常量可选： `dark-content` 和 `light-content`，在 Android 6.0 效果如下。

![topbar-default](../screenshot/topbar-default.png)

* topBarColor

可选，导航栏（UINavigationBar | ToolBar）背景颜色。如果不设置，将根据 topBarStyle 来计算，如果 topBarStyle 的值是 dark-content，那么 topBarColor 的值是白色，否则是黑色。

> 注意，可配置的颜色仅支持 #AARRGGBB 或者 #RRGGBB 格式的字符

* statusBarColor

可选，仅对 Android 5.0 以上版本生效。如果不设置，默认取 `topBarColor` 的值。

系统启动时，由于还没有设置 statusBarColor，状态栏颜色会出现前后不一致的情况，下图是应用还没启动好时，状态栏可能的颜色。和上面的黑白图对比，是不是有种违和感。

![statusbar-inperfect](../screenshot/statusbar-inperfect.png)

为了提供一致的用户体验，你可以为 Android 5.0 以上版本配置 `andriod:statusBarColor` 样式。

1.在 res 目录下新建一个名为 values-v21 的文件夹

![statusbar-setup-step-1](../screenshot/statusbar-setup-step-1.png)

2.在 values-v21 文件夹新建一个名为 styles.xml 的资源文件

![statusbar-setup-step-2](../screenshot/statusbar-setup-step-2.png)

3.双击打开 values-v21 目录中的 styles.xml 文件，把 App 主题样式 `andriod:statusBarColor` 的值设置成和你用 Garden 设置的一样。

```javascript
import { Garden } from 'react-native-navigation-hybrid';

Garden.setStyle({
  statusBarColor: '#ffffff',
});
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

* hideBackTitle

可选，仅对 iOS 生效，用来决定是否隐藏返回按钮旁边的文字，即前一个页面的标题

* elevation

可选，导航栏阴影高度，仅对 Android 5.0 以上版本生效，默认值为 4 dp

* shadowImage

可选，导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效。

```javascript
// index.js

import { Image } from 'react-native';
import { Garden } from 'react-native-navigation-hybrid';

Garden.setStyle({
  shadowImage: {
    // color 和 image 二选其一，如果选择 color ，默认生成 1 dp(pt) 高度的纯色图片
    color: '#cccccc',
    // image: Image.resolveAssetSource(require('./divider.png'))
  },
});
```

shadowImage 会有一个默认值，如果你想去掉，可以这样设置

```javascript
Garden.setStyle({
  shadowImage: {},
});
```

* backIcon

可选，配置返回按钮的图标。如果不配置，则采用平台默认的图标。配置方式如下

```javascript
// index.js

import { Image } from 'react-native';
import { Garden } from 'react-native-navigation-hybrid';

Garden.setStyle({
  backIcon: Image.resolveAssetSource(require('./ic_back.png')),
});
```

* topBarTintColor

可选，顶部导航栏标题和按钮的颜色。如果不设置，将根据 topBarStyle 来计算，如果 topBarStyle 的值是 dark-content，那么 topBarTintColor 的值是黑色，否则是白色。

* titleTextColor

可选，顶部导航栏标题的颜色。如果不设置，取 topBarTintColor 的值。

* titleTextSize

可选，顶部导航栏标题的字体大小，默认是 17 dp(pt)。

* titleAlignment

可选，顶部导航栏标题的位置，仅对 Android 生效，有 left 和 center 两个值可选，默认是 left

* barButtonItemTintColor

可选，顶部导航栏按钮的颜色。如果不设置， 取 topBarTintColor 的值。

* barButtonItemTextSize

可选，顶部导航栏按钮的字体大小，默认是 15 dp(pt)

* bottomBarColor

可选，UITabBar(iOS)、BottomNavigationBar(Android) 的背景颜色。

* bottomBarShadowImage

可选，UITabBar(iOS)、BottomNavigationBar(Android) 的阴影图片。仅对 iOS 和 Android 4.4 以下版本生效 ，对 iOS, 只有设置了 bottomBarBackgroundColor 才会生效配置方式请参考 `shadowImage`

<a name="static-options"></a>

* bottomBarButtonItemActiveColor

可选，底部 TabBarItem 选中效果

* bottomBarButtonItemInactiveColor

可选，底部 TabBarItem 未选中效果

## 静态配置页面

每个页面的标题、按钮，通常是固定的，我们可以通过静态的方式来配置。

我们需要在页面实现 `navigationItem` 这个静态字段，完整的可配置项如下：

```javascript
class Screen extends Component {
  static navigationItem = {
    passThroughTouches: false, // 当前页面是否允许穿透，通常和透明背景一起使用
    screenBackgroundColor: '#FFFFFF', // 当前页面背景
    topBarStyle: String; // 状态栏和导航栏前景色，可选值有 light-content 和 dark-content
    topBarColor: '#FDFF0000', // 当前页面 topBar 背景颜色，如果颜色带有透明度，则页面会延伸到 topBar 底下。 `topBarAlpha` 不能决定页面内容是否延伸到 topBar 底下
    topBarAlpha: 0.5, // 当前页面 topBar 背景透明度
    extendedLayoutIncludesTopBar: false, // 当前页面的内容是否延伸到 topBar 底下，通常用于需要动态改变 `topBarAlpha` 的场合
    topBarTintColor: '#FFFFFF', // 当前页面按钮颜色
    titleTextColor: '#FFFFFF', // 当前页面标题颜色
    topBarShadowHidden: true, // 是否隐藏当前页面 topBar 的阴影
    topBarHidden: true, // 是否隐藏当前页面 topBar
    statusBarHidden: true, // 是否隐藏当前页面的状态栏，iPhoneX 下，不管设置为何值都不隐藏
    backButtonHidden: true, // 当前页面是否隐藏返回按钮
    backInteractive: true, // 当前页面是否可以通过右滑或返回键返回
    swipeBackEnabled: true, // 当前页面是否可以通过右滑返回。Android 下，只有开启了侧滑返回功能，该值才会生效。如果 `backInteractive` 设置为 false, 那么该值无效。

    titleItem: {
      // 导航栏标题
      tilte: '这是标题',
      moduleName: 'ModuleName', // 自定义标题栏模块名
      layoutFitting: 'expanded', // 自定义标题栏填充模式，expanded 或 compressed
    },

    leftBarButtonItem: {
      // 导航栏左侧按钮
      title: '按钮',
      icon: Image.resolveAssetSource(require('./ic_settings.png')),
      insets: { top: -1, left: -8, bottom: 0, right: 0 },
      action: navigator => {
        navigator.toggleMenu();
      },
      enabled: true,
      tintColor: '#FFFF00',
    },

    rightBarButtonItem: {
      // 导航栏右侧按钮
      // 可配置项同 leftBarButtonItem
    },

    leftBarButtonItems: [
      {
        // 可配置项同 leftBarButtonItem
      },
      {
        // 可配置项同 leftBarButtonItem
      },
    ],

    rightBarButtonItems: [
      {
        // 可配置项同 leftBarButtonItem
      },
      {
        // 可配置项同 leftBarButtonItem
      },
    ],

    tabItem: {
      // 底部 TabBarItem 可配置项
      title: 'Style',
      icon: { uri: fontUri('FontAwesome', 'leaf', 20) },
      selectedIcon: { uri: fontUri('FontAwesome', 'leaf', 20) },
      hideTabBarWhenPush: true,
    },
  };
}
```

* topBarAlpha

可选，默认值是 1.0。 当前页面 topBar 背景透明度，如果想调整 topBar 透明度，请使用该配置项

* topBarColor

可选，该设置会在当前页面覆盖全局设置中 topBarColor 的值，颜色可以是透明的，如果单纯只想调整透明度，请使用 topBarAlpha

* topBarShadowHidden

可选，默认是 false。用来控制当前页面是否隐藏 topBar 的阴影

* topBarHidden

可选，默认值是 false。当前页面是否隐藏 topBar，同时会隐藏 topBar 的阴影

* backButtonHidden

可选，默认值是 false。用来控制是否隐藏当前页面的返回按钮。

* backInteractive

可选，默认值是 true。 禁止用户通过右滑（iOS）或返回键（Android）退出当前页面，通常用于有重要信息需要用户确认后才可退出当前页面的场景。

* titleItem

可选，设置页面标题。

title 设置页面标题。

moduleName 如果希望自定义标题栏，那么通过此配置项设置模块名，模块需要通过 ReactRegistry.registerComponent 注册。一旦设置了 moduleName，title 字段将失效

layoutFitting 配合 moduleName 使用，自定义标题栏的布局模式，有 expanded 和 compressed 两个可选值，默认是 compressed。 expanded 是指尽可能占据更多的空间， compressed 是指刚好能包裹自身内容。

当自定义标题栏时，可能需要将 backButtonHidden 设置为 true，以为标题栏提供更多的空间。

标题栏和所属页面共享同一个 navigator 对象，你可以在所属页面通过以下方式传递参数给标题栏使用

```javascript
this.props.navigator.setParams({});
```

详情请参考 playground 中 TopBarTitleView.js 这个文件。

* leftBarButtonItem

可选，设置导航栏左侧按钮。
title 是按钮标题，icon 是按钮图标，两者设置其一则可，如果同时设置，则只会显示图标。
insets 仅对 iOS 生效，用于调整按钮 icon 或 title 的位置。
action 是个函数，它接收 navigator 作为参数，当按钮被点击时调用。
enabled 是个布尔值，可选，用来标识按钮是否可以点击，默认是 true。

tintColor 按钮颜色，可选，覆盖全局设置，实现个性化颜色

* rightBarButtonItem

可选，导航栏右侧按钮，可配置项同 leftBarButtonItem。

* leftBarButtonItems

可选，导航栏左侧按钮，配置项是个数组，当有多个左侧按钮时使用。一旦设置此值，leftBarButtonItem 将会失效

* rightBarButtonItems

可选，导航栏右侧按钮，配置项是个数组，当有多个右侧按钮时使用。一旦设置此值，rightBarButtonItem 将会失效

* tabItem

可选，设置 UITabBar(iOS)、BottomNavigationBar(Android) 的 tab 标题和 icon。

如果同时设置了 icon 与 selectedIcon, 则保留图片原始颜色，否则用全局配置中的 `tabBarItemColor` 与 `tabBarSelectedItemColor` 对 icon 进行染色。

hideTabBarWhenPush, 当 Stack 嵌套在 Tab 的时候，push 到另一个页面时是否隐藏 TabBar

## 动态配置页面

有时，需要根据业务状态来动态改变导航栏中的项目。比如 rightBarButtonItem 是否可以点击，就是个很好的例子。

动态配置页面有两种方式，一种是页面跳转时，由前一个页面决定后一个页面的配置。另一种是当前页面根据应用状态来自行改变。

### 传值配置

譬如以下是 B 页面的静态配置

```javascript
// B.js
class B extends Component {
  static navigationItem = {
    titleItem: {
      tilte: 'B 的标题',
    },
    rightBarButtonItem: {
      title: 'B 的按钮',
      action: navigator => {},
    },
  };
}
```

正常情况下，B 的导航栏标题是 _B 的标题_，导航栏右侧按钮的标题是 _B 的按钮_。

从 A 页面跳转到 B 页面时，我们可以改变 B 页面中的静态设置

```javascript
// A.js
this.props.navigator.push(
  'B',
  {
    /*props*/
  },
  {
    titleItem: {
      title: '来自 A 的标题',
    },
    rightBarButtonItem: {
      title: '来自 A 的按钮',
    },
  }
);
```

那么，如果 B 页面是从 A 跳过来的，那么 B 的导航栏标题就会变成 _来自 A 的标题_ ，导航栏右侧按钮的标题就会变成 _来自 A 的按钮_。

### 动态配置

Garden 提供了一些实例方法，来帮助我们动态改变这些项目。

* setStatusBarColor

动态更改状态栏背景颜色，仅对 Android 生效

```javascript
this.props.garden.setStatusBarColor({ statusBarColor: '#FF0000' });
```

* setStatusBarHidden

动态隐藏或显示状态栏

```javascript
this.props.garden.setStatusBarHidden(false);
```

* setTopBarStyle

动态改变导航栏样式风格（会影响状态栏前景色是黑的或白的）

```javascript
this.props.garden.setTopBarStyle({ topBarStyle: this.state.topBarStyle });
if (this.state.topBarStyle === 'dark-content') {
  this.setState({ topBarStyle: 'light-content' });
} else {
  this.setState({ topBarStyle: 'dark-content' });
}
```

* setTopBarAlpha

动态改变导航栏背景的透明度

```javascript
this.props.garden.setTopBarAlpha({
  topBarAlpha: value,
});
```

* setTopBarColor

动态改变导航栏的颜色

```javascript
this.props.garden.setTopBarColor({ topBarColor: '#00FF00' });
```

* setTopBarShadowHidden

是否隐藏导航栏下的阴影

```javascript
this.props.garden.setTopBarShadowHidden({ topBarShadowHidden: value });
```

* setTitleItem

更改标题

```javascript
this.props.garden.setTitleItem({
  title: '新的标题',
});
```

* setLeftBarButtonItem

更改左侧按钮

```javascript
this.props.garden.setLeftBarButtonItem({
  title: 'Cancel',
  insets: { top: -1, left: -8, bottom: 0, right: 8 },
  action: navigator => {
    navigator.dismiss();
  },
});
```

* setRightBarButtonItem

更改右侧按钮

```javascript
this.props.garden.setRightBarButtonItem({
  enabled: false,
});
```

* setTabBarColor

更改 TabBar 的背景颜色

```javascript
this.props.garden.setTabBarColor({ bottomBarColor: '#FFFFFF' });
```

* replaceTabIcon

替换 tab 图标

```javascript
this.props.garden.replaceTabIcon(1, { uri: 'blue_solid', scale: PixelRatio.get() });
```

* setTabBadge

设置 badge

```javascript
if (this.state.badge) {
  this.props.garden.setTabBadge(1, null);
} else {
  this.props.garden.setTabBadge(1, '99');
}
```

* showRedPointAtIndex

显示小红点

```javascript
this.props.garden.showRedPointAtIndex(0);
```

* hideRedPointAtIndex

隐藏小红点

```javascript
this.props.garden.hideRedPointAtIndex(0);
```

* setMenuInteractive

是否允许侧滑打开抽屉

```javascript
componentDidAppear() {
    this.props.garden.setMenuInteractive(true);
}

componentDidDisappear() {
    this.props.garden.setMenuInteractive(false);
}
```
