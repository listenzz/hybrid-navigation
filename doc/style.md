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
  screenBackgroundColor: string; // 页面背景，默认是白色
  topBarStyle: string; // 状态栏和导航栏前景色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor: string; // 顶部导航栏背景颜色，默认根据 topBarStyle 来计算
  statusBarColorAndroid: string; // 状态栏背景色，默认取 topBarColor 的值， 仅对 Android 5.0 以上版本生效
  navigationBarColorAndroid: string; // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
  hideBackTitleIOS: boolean; // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
  elevationAndroid: number; // 导航栏阴影高度，默认值为 4 dp， 仅对 Android 5.0 以上版本生效
  shadowImage: object; // 导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效
  backIcon: object; // 返回按钮图片
  topBarTintColor: string; // 顶部导航栏按钮的颜色。默认根据 topBarStyle 来计算
  titleTextColor: string; // 顶部导航栏标题颜色，默认根据 topBarStyle 来计算
  titleTextSize: number; // 顶部导航栏标题字体大小，默认是 17 dp(pt)
  titleAlignmentAndroid: string; // 顶部导航栏标题的位置，可选项有 `TitleAlignmentLeft` 和 `TitleAlignmentCenter` ，仅对 Android 生效
  barButtonItemTextSize: number; // 顶部导航栏按钮字体大小，默认是 15 dp(pt)
  swipeBackEnabledAndroid: boolean; // Android 是否开启右滑返回，默认是 false
  optimizationEnabledAndroid: boolean; // Android 是否需要开启优化，默认是 true，可在指定页面关闭。

  tabBarColor: string; // 底部 TabBar 背景颜色，请勿使用带透明度的颜色。
  tabBarShadowImage: object; // 底部 TabBar 阴影图片。对于 iOS, 只有同时设置了 tabBarColor 才会生效
  tabBarItemColor: string; // 当 `tabBarSelectedItemColor` 未设置时，此值为选中效果，否则为未选中效果
  tabBarSelectedItemColor: string; // 底部 TabBarItem icon 选中效果
  badgeColor: string; // Badge 以及小红点的颜色
}
```

> 全局设置主题，有些样式需要重新运行原生应用才能看到效果。

> 所有关于颜色的设置，仅支持 #AARRGGBB 或者 #RRGGBB 格式的字符。

> 所有可配置项均是可选

- topBarStyle

导航栏和状态栏前景色，在 iOS 中，默认是白底黑字，在 Android 中，默认是黑底白字。

可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`，在 Android 6.0 效果如下：

![topbar-default](../screenshot/topbar-default.png)

- statusBarColor

仅对 Android 5.0 以上版本生效。默认取 `topBarColor` 的值。

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

- shadowImage

导航栏阴影图片，仅对 iOS 和 Android 4.4 以下版本生效。

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

- backIcon

配置返回按钮的图标。如果不配置，则采用平台默认的图标。配置方式如下

```javascript
// index.js

import { Image } from 'react-native';
import { Garden } from 'react-native-navigation-hybrid';

Garden.setStyle({
  backIcon: Image.resolveAssetSource(require('./ic_back.png')),
});
```

- tabBarShadowImage

UITabBar(iOS)、BottomNavigationBar(Android) 的阴影图片。对于 iOS, 只有设置了 tabBarColor 才会生效。

配置方式请参考 `shadowImage`

- navigationBarColorAndroid

  用于修改虚拟键的背景颜色，对 Andriod 8.0 以上版本生效。默认规则如下：

  - 含「底部 Tab」的页面，虚拟键设置为「底部 Tab」的颜色

  - 不含「底部 Tab」的页面，默认使用页面背景颜色，也就是 screenBackgroundColor

  - modal 默认是透明色

  一旦全局设置了 navigationBarColorAndroid，默认规则就会失效。

- optimizationEnabledAndroid

  目前只有这个作用：Android 的 tab 页面是否开启懒加载，默认是 true。

<a name="static-options"></a>

## 静态配置页面

每个页面的标题、按钮，通常是固定的，我们可以通过静态的方式来配置。

我们需要在页面实现 `navigationItem` 这个静态字段，完整的可配置项如下：

```javascript
class Screen extends Component {
  static navigationItem = {
    passThroughTouches: false, // 当前页面是否允许 touch 事件穿透，通常和透明的 `screenBackgroundColor` 一起使用
    screenBackgroundColor: '#FFFFFF', // 当前页面背景
    topBarStyle: string, // 状态栏和导航栏前景色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
    topBarColor: '#FDFF0000', // 当前页面 topBar 背景颜色，如果颜色带有透明度，则页面会延伸到 topBar 底下。
    topBarAlpha: 0.5, // 当前页面 topBar 背景透明度
    extendedLayoutIncludesTopBar: false, // 当前页面的内容是否延伸到 topBar 底下，通常用于需要动态改变 `topBarAlpha` 的场合
    topBarTintColor: '#FFFFFF', // 当前页面按钮颜色
    titleTextColor: '#FFFFFF', // 当前页面标题颜色
    titleTextSize: Int, // 当前页面顶部导航栏标题字体大小
    topBarShadowHidden: true, // 是否隐藏当前页面 topBar 的阴影
    topBarHidden: true, // 是否隐藏当前页面 topBar
    statusBarHidden: true, // 是否隐藏当前页面的状态栏，对 iPhoneX 无效
    statusBarColorAndroid: string, // 状态栏颜色，仅对 Android 生效
    navigationBarColorAndroid: string, // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
    backButtonHidden: true, // 当前页面是否隐藏返回按钮
    backInteractive: true, // 当前页面是否可以通过右滑或返回键返回
    swipeBackEnabled: true, // 当前页面是否可以通过右滑返回。如果 `backInteractive` 设置为 false, 那么该值无效。Android 下，只有开启了侧滑返回功能，该值才会生效。
    optimizationEnabledAndroid: boolean; // 当前页面是否需要优化。

    titleItem: {
      // 导航栏标题
      tilte: '这是标题',
      // 自定义标题栏模块名
      moduleName: 'ModuleName',
      // 自定义标题栏填充模式，可选项有 `LayoutFittingExpanded` 和  `LayoutFittingCompressed`。仅对自定义标题模块生效
      layoutFitting: 'expanded',
    },

    // 导航栏左侧按钮
    leftBarButtonItem: {
      // 按钮文字，如果设置了 icon ，将会失效
      title: '按钮',
      // icon 图片
      icon: Image.resolveAssetSource(require('./ic_settings.png')),
      // 图片位置调整，仅对 iOS 生效
      insetsIOS: { top: -1, left: -8, bottom: 0, right: 0 },
      // 按钮点击事件处理
      action: navigator => {
        navigator.toggleMenu();
      },
      // 按钮是否可以点击
      enabled: true,
      // 按钮颜色
      tintColor: '#FFFF00', // 默认取 topBarTintColor 的值
      renderOriginal: true, // 是否保留图片原来的颜色，默认为 false，如果该值为 true，tintColor 将失效
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

    // 返回按钮文字和颜色，仅对 iOS 生效
    backItemIOS: {
      title: 'Back',
      tintColor: '#000000', // 仅对 iOS 11.0 以上生效
    },

    // 底部 TabBarItem 可配置项
    tabItem: {
      // tab 标题文字
      title: 'Style',
      // tab 图片
      icon: { uri: fontUri('FontAwesome', 'leaf', 20) },
      // tab 选中时的图片，可选
      selectedIcon: { uri: fontUri('FontAwesome', 'leaf', 20) },
      // push 时是否隐藏 tabBar
      hideTabBarWhenPush: true,
    },
  };
}
```

- titleItem

如果希望自定义标题栏，可以通过 moduleName 来指定标题栏对应的组件。组件需要通过 ReactRegistry.registerComponent 注册。一旦设置了 moduleName，title 字段将失效。

layoutFitting 配合 moduleName 使用，自定义标题栏的布局模式，有 expanded 和 compressed 两个可选值，默认是 compressed。 expanded 是指尽可能占据更多的空间， compressed 是指刚好能包裹自身内容。

当自定义标题栏时，可能需要将 backButtonHidden 设置为 true，以为标题栏提供更多的空间。

标题栏和所属页面共享同一个 navigator 对象，你可以在所属页面通过以下方式传递参数给标题栏使用

```javascript
this.props.navigator.setParams({});
```

详情请参考 playground 中 TopBarTitleView.js 这个文件。

- tabItem

如果同时设置了 icon 与 selectedIcon, 则保留图片原始颜色，否则用全局配置中的 `tabBarItemColor` 与 `tabBarSelectedItemColor` 对 icon 进行染色。

hideTabBarWhenPush 表示当 stack 嵌套在 tabs 的时候，push 到另一个页面时是否隐藏 TabBar。

- navigationBarColorAndroid

  用于修改虚拟键的背景颜色，对 Andriod 8.0 以上版本生效。默认规则如下：

  - 含「底部 Tab」的页面，虚拟键设置为「底部 Tab」的颜色

  - 不含「底部 Tab」的页面，默认使用页面背景颜色，也就是 screenBackgroundColor

  - modal 默认是透明色

  某些页面，比如从底部往上滑的 modal, 需要开发者使用 navigationBarColorAndroid 自行适配，请参考 playground/src/ReactModal.js 这个文件

## 动态配置页面

有时，需要根据业务状态来动态改变导航栏中的项目。比如 rightBarButtonItem 是否可以点击，就是个很好的例子。

动态配置页面有两种方式，一种是页面跳转时，由前一个页面决定后一个页面的配置（传值配置）。另一种是当前页面根据应用状态来动态改变（动态配置）。

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

- setStatusBarColorAndroid

动态更改状态栏背景颜色，仅对 Android 生效

```javascript
this.props.garden.setStatusBarColorAndroid({ statusBarColor: '#FF0000' });
```

- setStatusBarHidden

动态隐藏或显示状态栏

```javascript
this.props.garden.setStatusBarHidden(false);
```

- updateTopBar

动态改变导航栏样式, 可配置项如下

```javascript
this.props.garden.updateTopBar({
  topBarStyle: BarStyleLightContent, // 状态栏和导航栏前景色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor: '#FDFF0000', // 当前页面 topBar 背景颜色，如果颜色带有透明度，则页面会延伸到 topBar 底下
  topBarAlpha: 0.5, // 当前页面 topBar 背景透明度
  topBarShadowHidden: true, // 是否隐藏当前页面 topBar 的阴影
  topBarTintColor: '#FFFFFF', // 当前页面按钮颜色
  titleTextColor: '#FFFFFF', // 当前页面标题颜色
  titleTextSize: 17, // 当前页面顶部导航栏标题字体大小
  backInteractive: false, // 是否允许侧滑返回或通过返回键返回，默认是 true
  backButtonHidden: false, // 是否显示返回按钮，默认是 true
});
```

- setTitleItem

更改标题

```javascript
this.props.garden.setTitleItem({
  title: '新的标题',
});
```

- setLeftBarButtonItem

更改左侧按钮

```javascript
this.props.garden.setLeftBarButtonItem({
  title: 'Cancel',
  insetsIOS: { top: -1, left: -8, bottom: 0, right: 8 },
  action: navigator => {
    navigator.dismiss();
  },
});
```

- setRightBarButtonItem

更改右侧按钮

```javascript
this.props.garden.setRightBarButtonItem({
  enabled: false,
});
```

- updateTabBar

动态改变 tabBar 样式, 可配置项如下

```javascript
this.props.garden.updateTabBar({
  tabBarColor: '#FFFFFF',
  tabBarShadowImage: {
    color: '#DDDDDD',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  tabBarItemColor: '#8BC34A',
  tabBarUnselectedItemColor: '#BDBDBD',
});
```

- replaceTabIcon

替换 tab 图标

```javascript
this.props.garden.replaceTabIcon(1, { uri: 'blue_solid', scale: PixelRatio.get() });
```

- setTabBadge

设置 badge

```ts
export interface Badge {
  index: number;
  text?: string;
  hidden: boolean;
  dot?: boolean; // 是否作为红点显示
}
```

```javascript
if (hideBadge) {
  this.props.garden.setTabBadge([{ index: 0, hidden: true }, { index: 1, hidden: true }]);
} else {
  this.props.garden.setTabBadge([
    { index: 0, hidden: false, dot: true },
    { index: 1, hidden: false, text: '99' },
  ]);
}
```

- setMenuInteractive

是否允许侧滑打开抽屉

```javascript
componentDidAppear() {
  this.props.garden.setMenuInteractive(true);
}

componentDidDisappear() {
  this.props.garden.setMenuInteractive(false);
}
```
