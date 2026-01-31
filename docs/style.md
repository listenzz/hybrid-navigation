# 样式和主题

一个 APP 中的风格通常是一致的，使用 `Navigation.setDefaultOptions` 可以全局设置 APP 的主题。

我们提供了三种设置图片的方式

1.  加载静态图片

```ts
import { Image } from 'react-native';

icon: Image.resolveAssetSource(require('./images/ic_settings.png')),
```

2.  加载原生图片

```ts
import { PixelRatio } from 'react-native';

icon: { uri: 'flower', scale: PixelRatio.get() },
```

3.  加载网络图片（不推荐）

```ts
icon: {
  uri: 'http://xxx.xx/?width=24&height=24&scale=3';
}
```

会占用主线程，导致卡顿，并且没有缓存

4.  使用 icon font

```ts
icon: { uri: fontUri('FontAwesome', 'navicon', 24)},
```

如果项目中使用了 react-native-vector-icons 这样的库，请参考 example 中 Options.js 这个文件

## 设置全局主题

我们通过 `Navigation.setDefaultOptions(options: DefaultOptions)` 来设置全局样式。可配置项如下：

```ts
export interface DefaultOptions {
  screenBackgroundColor?: Color; // 页面背景，默认是白色
  topBarStyle?: BarStyle; // TopBar 样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor?: Color; // TopBar 背景颜色，默认根据 topBarStyle 来计算
  topBarColorDarkContent?: Color; // TopBar 背景颜色，当 topBarStyle 的值为 BarStyleDarkContent 时生效，覆盖 topBarColor 的值
  topBarColorLightContent?: Color; // TopBar 背景颜色，当 topBarStyle 的值为 BarStyleLightContent 时生效，覆盖 topBarColor 的值
  navigationBarColorAndroid?: Color; // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
  hideBackTitleIOS?: boolean; // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
  elevationAndroid?: number; // TopBar 阴影高度，默认值为 4 dp
  shadowImage?: ShadowImage; // TopBar 阴影图片，仅对 iOS 生效
  backIcon?: ImageSource; // 返回按钮图片
  topBarTintColor?: Color; // TopBar 按钮的颜色。默认根据 topBarStyle 来计算
  topBarTintColorDarkContent?: Color; // TopBar 按钮颜色，当 topBarStyle 的值为 BarStyleDarkContent 时生效，覆盖 topBarTintColor 的值
  topBarTintColorLightContent?: Color; // TopBar 按钮颜色，当 topBarStyle 的值为 BarStyleLightContent 时生效，覆盖 topBarTintColor 的值
  titleTextColor?: Color; // TopBar 标题颜色，默认根据 topBarStyle 来计算
  titleTextColorDarkContent?: Color; // TopBar 标题颜色，当 topBarStyle 的值为 BarStyleDarkContent 时生效，覆盖 titleTextColor 的值
  titleTextColorLightContent?: Color; // TopBar 标题颜色，当 topBarStyle 的值为 BarStyleLightContent 时生效，覆盖 titleTextColor 的值
  titleTextSize?: number; // TopBar 标题字体大小，默认是 17 dp(pt)
  titleAlignmentAndroid?: TitleAlignment; // TopBar 标题的位置，可选项有 `TitleAlignmentLeft` 和 `TitleAlignmentCenter` ，仅对 Android 生效
  barButtonItemTextSize?: number; // TopBar 按钮字体大小，默认是 15 dp(pt)
  swipeBackEnabledAndroid?: boolean; // Android 是否开启右滑返回，默认是 false
  splitTopBarTransitionIOS?: boolean; // iOS 侧滑返回时，是否总是割裂导航栏背景
  scrimAlphaAndroid?: number; // Android 侧滑返回遮罩效果 [0 - 255]
  fitsOpaqueNavigationBarAndroid?: boolean; // 适配不透明的导航栏边衬区，默认为 true
  displayCutoutWhenLandscapeAndroid?: boolean; // 横屏时，是否将界面延伸至刘海区域，默认 true

  tabBarBackgroundColor?: Color; // 底部 TabBar 背景颜色，请勿使用带透明度的颜色。
  tabBarShadowImage?: ShadowImage; // 底部 TabBar 阴影图片。对于 iOS, 只有同时设置了 tabBarBackgroundColor 才会生效
  tabBarItemSelectedColor?: Color; // 底部 TabBarItem icon 选中颜色
  tabBarItemNormalColor?: Color; // 底部 TabBarItem icon 未选中颜色，默认为 #666666
  tabBarBadgeColor?: Color; // Tab badge 颜色
}

export type Color = string;
export type ImageSource = {
  uri: string;
  scale?: number;
  height?: number;
  width?: number;
};
export interface ShadowImage {
  image?: ImageSource;
  color?: Color;
}

export const BarStyleLightContent = 'light-content';
export const BarStyleDarkContent = 'dark-content';
export type BarStyle = BarStyleLightContent | BarStyleDarkContent;

export const TitleAlignmentLeft = 'left';
export const TitleAlignmentCenter = 'center';
export type TitleAlignment = TitleAlignmentCenter | TitleAlignmentLeft;
```

::: warning

- 全局设置主题，有些样式需要重新运行原生应用才能看到效果。

- 所有关于颜色的设置，仅支持 #AARRGGBB 或者 #RRGGBB 格式的字符。

- 所有可配置项均是可选

:::

### topBarStyle

导航栏和状态栏前景色，在 iOS 中，默认是白底黑字，在 Android 中，默认是黑底白字。

可选项有 `BarStyleDarkContent` 和 `BarStyleLightContent`，在 Android 6.0 效果如下：

![style-2021-10-19-15-43-21](https://todoit.oss-cn-shanghai.aliyuncs.com/todoit/style-2021-10-19-15-43-21.png)

### topBarColor

TopBar 背景颜色，默认根据 `topBarStyle` 来计算。你也可以通过 `topBarColorDarkContent` 和 `topBarColorLightContent` 分别为不同的样式设置不同的背景颜色。

系统启动时，由于还没有设置 topBarColor，状态栏颜色会出现前后不一致的情况。为了提供一致的用户体验，你可以为 Android 配置 `android:statusBarColor` 样式。

1. 在 res 目录下新建一个名为 values-v21 的文件夹

![style-2021-10-19-15-44-13](https://todoit.oss-cn-shanghai.aliyuncs.com/todoit/style-2021-10-19-15-44-13.png)

2. 在 values-v21 文件夹新建一个名为 styles.xml 的资源文件

![style-2021-10-19-15-44-33](https://todoit.oss-cn-shanghai.aliyuncs.com/todoit/style-2021-10-19-15-44-33.png)

3. 双击打开 values-v21 目录中的 styles.xml 文件，把 App 主题样式 `android:statusBarColor` 的值设置成和你用 `Navigation.setDefaultOptions` 设置的一样。

```ts
import Navigation from 'hybrid-navigation';

Navigation.setDefaultOptions({
  topBarColor: '#ffffff',
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

### shadowImage

导航栏阴影图片，仅对 iOS 生效。

```ts
// index.js

import { Image } from 'react-native';
import Navigation from 'hybrid-navigation';

Navigation.setDefaultOptions({
  shadowImage: {
    // color 和 image 二选其一，如果选择 color ，默认生成 1 dp(pt) 高度的纯色图片
    color: '#cccccc',
    // image: Image.resolveAssetSource(require('./divider.png'))
  },
});
```

shadowImage 会有一个默认值，如果你想去掉，可以这样设置

```ts
Navigation.setDefaultOptions({
  shadowImage: {},
});
```

### backIcon

配置返回按钮的图标。如果不配置，则采用平台默认的图标。配置方式如下

```ts
// index.js

import { Image } from 'react-native';
import Navigation from 'hybrid-navigation';

Navigation.setDefaultOptions({
  backIcon: Image.resolveAssetSource(require('./ic_back.png')),
});
```

### tabBarShadowImage

UITabBar(iOS)、BottomNavigationBar(Android) 的阴影图片。对于 iOS, 只有同时设置了 `tabBarBackgroundColor` 才会生效。

配置方式请参考 [shadowImage](#shadowimage)

### navigationBarColorAndroid

用于修改底部虚拟键的背景颜色，对 Andriod 8.0 以上版本生效。默认规则如下：

- 含「底部 Tab」的页面，虚拟键设置为「底部 Tab」的颜色

- 不含「底部 Tab」的页面，默认使用页面背景颜色，也就是 screenBackgroundColor

- modal 默认是透明色

一旦全局设置了 navigationBarColorAndroid，默认规则就会失效。

## 静态配置页面

每个页面的标题、按钮，通常是固定的，我们可以通过静态的方式来配置。

我们需要在页面实现 `navigationItem` 这个静态字段，完整的可配置项如下：

```ts
class Screen extends Component {
  static navigationItem: NavigationItem = {
    passThroughTouches: false, // 触摸事件是否可以穿透到下一层页面，很少用。
    screenBackgroundColor: '#FFFFFF', // 当前页面背景
    topBarStyle: string, // 状态栏和导航栏前景色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
    topBarColor: '#FDFF0000', // 当前页面顶部导航栏背景颜色，如果颜色带有透明度，则页面会延伸到 topBar 底下。
    topBarAlpha: 0.5, // 当前页面顶部导航背景透明度
    extendedLayoutIncludesTopBar: false, // 当前页面的内容是否延伸到 topBar 底下，通常用于需要动态改变 `topBarAlpha` 的场合
    topBarTintColor: '#FFFFFF', // 当前页面按钮颜色
    titleTextColor: '#FFFFFF', // 当前页面标题颜色
    titleTextSize: Int, // 当前页面顶部导航栏标题字体大小
    topBarShadowHidden: true, // 是否隐藏当前页面 topBar 的阴影
    topBarHidden: true, // 是否隐藏当前页面 topBar
    statusBarHidden: true, // 是否隐藏当前页面的状态栏，对 iPhoneX 无效
    navigationBarColorAndroid: string, // 底部虚拟键背景颜色，仅对 Android 8.0 以上版本生效
    navigationBarHiddenAndroid: boolean, // 是否隐藏 Android 底部的虚拟导航栏
    fitsOpaqueNavigationBarAndroid: boolean, // 适配不透明的导航栏边衬区，默认为 true
    displayCutoutWhenLandscapeAndroid: boolean, // 横屏时，是否将界面延伸至刘海区域，默认 true
    homeIndicatorAutoHiddenIOS: boolean, // 是否隐藏 Home 指示器，默认 false

    backButtonHidden: true, // 当前页面是否隐藏返回按钮
    backInteractive: true, // 当前页面是否可以通过右滑或返回键返回
    swipeBackEnabled: true, // 当前页面是否可以通过右滑返回。如果 `backInteractive` 设置为 false, 那么该值无效。Android 下，只有开启了侧滑返回功能，该值才会生效。

    titleItem: {
      // 导航栏标题
      title: '这是标题',
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
      // tab 图片，可选
      icon: { uri: fontUri('FontAwesome', 'leaf', 20) },
      // tab 未选中时的图片，可选，只有设置了 icon，unselectedIcon 才会生效
      unselectedIcon: { uri: fontUri('FontAwesome', 'leaf', 20) },
      // push 时是否隐藏 tabBar
      hideTabBarWhenPush: true,
    },
  };
}
```

### extendedLayoutIncludesTopBar

默认情况下，这个值根据 `topBarColor` 的初始值计算得出，如果 `topBarColor` 含有透明度，那么这个值为 true，否则为 false。通常用于需要动态改变 `topBarAlpha` 的场合。参看 [example/TopBarAlpha](https://github.com/listenzz/hybrid-navigation/blob/master/example/src/TopBarAlpha.js) 这个例子。

### titleItem

如果希望自定义标题栏，可以通过 moduleName 来指定标题栏对应的组件。组件需要通过 Navigation.registerComponent 注册。一旦设置了 moduleName，title 字段将失效。

layoutFitting 配合 moduleName 使用，自定义标题栏的布局模式，有 expanded 和 compressed 两个可选值，默认是 compressed。 expanded 是指尽可能占据更多的空间， compressed 是指刚好能包裹自身内容。

当自定义标题栏时，可能需要将 backButtonHidden 设置为 true，以为标题栏提供更多的空间。

标题栏和所属页面共享同一个 navigator 对象，你可以在所属页面通过以下方式传递参数给标题栏使用

```ts
navigator.setParams({});
```

详情请参考 example 中 TopBarTitleView.js 这个文件。

### tabItem

如果同时设置了 icon 与 unselectedIcon, 则保留图片原始颜色，否则用全局配置中的 `tabBarItemSelectedColor` 与 `tabBarItemNormalColor` 对 icon 进行染色。

hideTabBarWhenPush 表示当 stack 嵌套在 tabs 的时候，push 到另一个页面时是否隐藏 TabBar。

### navigationBarColorAndroid

用于修改当前页面对应的虚拟键的背景颜色，对 Andriod 8.0 以上版本生效。

某些页面，比如从底部往上滑的 modal, 需要开发者使用 navigationBarColorAndroid 自行适配，请参考 example/src/ReactModal.js 这个文件

## 动态配置页面

有时，需要根据业务状态来动态改变导航栏中的项目。比如 rightBarButtonItem 是否可以点击，就是个很好的例子。

动态配置页面有两种方式，一种是页面跳转时，由前一个页面决定后一个页面的配置（传值配置）。另一种是当前页面根据应用状态来动态改变（动态配置）。

### 传值配置

譬如以下是 B 页面的静态配置

```ts
// B.js
class B extends Component {
  static navigationItem = {
    titleItem: {
      title: 'B 的标题',
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

```ts
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
  },
);
```

那么，如果 B 页面是从 A 跳过来的，那么 B 的导航栏标题就会变成 _来自 A 的标题_ ，导航栏右侧按钮的标题就会变成 _来自 A 的按钮_。

### 动态配置

Garden 提供了一些实例方法，来帮助我们动态改变这些项目。

#### updateOptions

`Navigation.updateOptions(sceneId: string, options: NavigationOption)` 动态改变设置, 可配置项如下

```ts
export interface NavigationOption {
  screenBackgroundColor?: Color; // 页面背景，默认是白色
  statusBarHidden?: boolean; // 是否隐藏状态栏
  topBarStyle?: BarStyle; // TopBar 样式，决定了状态栏的颜色，可选项有 `BarStyleLightContent` 和 `BarStyleDarkContent`
  topBarColor?: Color; // TopBar 背景颜色
  topBarShadowHidden?: boolean; // 是否隐藏 TopBar 的阴影
  topBarAlpha?: number; // TopBar 背景透明度
  topBarTintColor?: Color; // TopBar 按钮颜色
  titleTextColor?: Color; // TopBar 标题字体颜色
  titleTextSize?: number; // TopBar 标题字体大小
  navigationBarColorAndroid?: Color; // Android 底部虚拟按钮背景颜色
  navigationBarHiddenAndroid?: boolean; // 是否隐藏 Android 底部的虚拟导航栏
  fitsOpaqueNavigationBarAndroid?: boolean; // 适配不透明的导航栏边衬区，默认为 true
  displayCutoutWhenLandscapeAndroid?: boolean; // 横屏时，是否将界面延伸至刘海区域，默认 true
  homeIndicatorAutoHiddenIOS?: boolean; // 是否隐藏 Home 指示器，默认 false
  backButtonHidden?: boolean; // 是否显示返回按钮
  backInteractive?: boolean; // 是否允许侧滑返回或通过返回键返回
}
```

#### setTitleItem

`Navigation.setTitleItem(sceneId: string, titleItem: TitleItem)` 更改标题

```ts
export interface TitleItem {
  title?: string;
  moduleName?: string;
  layoutFitting?: LayoutFitting;
}
```

```ts
import Navigation from 'hybrid-navigation';

Navigation.setTitleItem(sceneId, {
  title: '新的标题',
});
```

#### setLeftBarButtonItem

`setLeftBarButtonItem(buttonItem: BarButtonItem)` 更改左侧按钮

```ts
export interface BarButtonItem {
  title?: string;
  icon?: ImageSource;
  action?: (navigator: Navigator) => void;
  enabled?: boolean;
  tintColor?: Color;
  renderOriginal?: boolean;
}
```

```ts
import Navigation from 'hybrid-navigation';
import { Image } from 'react-native';

Navigation.setLeftBarButtonItem(sceneId, {
  title: 'Cancel',
  icon: Image.resolveAssetSource(require('./ic_cancel.png')),
  action: navigator => {
    navigator.dismiss();
  },
});
```

#### setRightBarButtonItem

`Navigation.setRightBarButtonItem(sceneId: string, buttonItem: BarButtonItem | null)` 更改右侧按钮

```ts
import Navigation from 'hybrid-navigation';

Navigation.setRightBarButtonItem(sceneId, {
  enabled: false,
});
```

#### updateTabBar

动态改变 tabBar 样式, 可配置项如下

```ts
import Navigation from 'hybrid-navigation';

Navigation.updateTabBar(sceneId, {
  tabBarBackgroundColor: '#FFFFFF',
  tabBarShadowImage: {
    color: '#DDDDDD',
    // image: Image.resolveAssetSource(require('./src/images/divider.png')),
  },
  tabBarItemSelectedColor: '#8BC34A',
  tabBarItemNormalColor: '#BDBDBD',
});
```

#### setTabItem

`setTabItem(item: TabItemInfo | TabItemInfo[])` 动态设置 tab 的图标、文字、徽章

```ts
export interface TabItemInfo {
  index: number;
  title?: string;
  badge?: {
    text?: string;
    hidden: boolean;
    dot?: boolean;
  };
  icon?: {
    selected: ImageSource;
    unselected?: ImageSource;
  };
}
```

```ts
import Navigation from 'hybrid-navigation';
import { Image } from 'react-native';

Navigation.setTabItem(sceneId, {
  index: 1,
  icon: {
    selected: Image.resolveAssetSource(require('./images/ic_settings.png')),
  },
  title: '选项',
});
```

#### setMenuInteractive

`setMenuInteractive(enabled: boolean)` 是否允许侧滑打开抽屉

```ts
import { useVisibleEffect, useNavigator } from 'hybrid-navigation';
import Navigation from 'hybrid-navigation';
import { useCallback } from 'react';

const navigator = useNavigator();
useVisibleEffect(
  useCallback(() => {
    Navigation.setMenuInteractive(navigator.sceneId, true);
    return () => {
      Navigation.setMenuInteractive(navigator.sceneId, false);
    };
  }, [navigator]),
);
```
