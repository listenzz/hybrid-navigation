# 设置样式

从本版本开始，`hybrid-navigation` 不再提供原生 TopBar（导航栏）能力。页面顶部 UI 由 RN 自行实现，推荐在业务侧封装统一的 RN TopBar 组件。

## 全局样式

通过 `Navigation.setDefaultOptions(options)` 设置全局默认样式。

```ts
import Navigation, { BarStyleDarkContent } from 'hybrid-navigation';

Navigation.setDefaultOptions({
  screenBackgroundColor: '#F8F8F8',
  statusBarStyle: BarStyleDarkContent,
  navigationBarColorAndroid: '#FFFFFF',
  swipeBackEnabledAndroid: true,
  fitsOpaqueNavigationBarAndroid: true,
  displayCutoutWhenLandscapeAndroid: true,
  tabBarBackgroundColor: '#FFFFFF',
  tabBarItemNormalColor: '#666666',
  tabBarItemSelectedColor: '#FF5722',
});
```

### DefaultOptions

```ts
interface DefaultOptions {
  screenBackgroundColor?: string;
  statusBarStyle?: 'light-content' | 'dark-content';
  navigationBarColorAndroid?: string;
  swipeBackEnabledAndroid?: boolean;
  scrimAlphaAndroid?: number;
  fitsOpaqueNavigationBarAndroid?: boolean;
  displayCutoutWhenLandscapeAndroid?: boolean;

  tabBarBackgroundColor?: string;
  tabBarShadowImage?: {
    image?: { uri: string; scale?: number; height?: number; width?: number };
    color?: string;
  };
  tabBarItemSelectedColor?: string;
  tabBarItemNormalColor?: string;
  tabBarBadgeColor?: string;
}
```

## 页面样式

页面级样式可通过两种方式设置：

1. 组件静态配置：`withNavigationItem(item)`
2. 运行时更新：`Navigation.updateOptions(sceneId, options)`

### NavigationOption

```ts
interface NavigationOption {
  screenBackgroundColor?: string;
  statusBarHidden?: boolean;
  statusBarStyle?: 'light-content' | 'dark-content';
  navigationBarColorAndroid?: string;
  navigationBarHiddenAndroid?: boolean;
  fitsOpaqueNavigationBarAndroid?: boolean;
  displayCutoutWhenLandscapeAndroid?: boolean;
  homeIndicatorAutoHiddenIOS?: boolean;
  backInteractive?: boolean;
}
```

### NavigationItem

```ts
interface NavigationItem extends NavigationOption {
  passThroughTouches?: boolean;
  forceTransparentDialogWindow?: boolean; // 历史兼容字段：控制 modal 覆盖层背景是否透明
  animatedTransition?: boolean;
  forceScreenLandscape?: boolean;
  swipeBackEnabled?: boolean;
  tabItem?: {
    title: string;
    icon?: { uri: string; scale?: number; height?: number; width?: number };
    unselectedIcon?: { uri: string; scale?: number; height?: number; width?: number };
    hideTabBarWhenPush?: boolean;
  };
}
```

## 状态栏

### statusBarStyle

- `light-content`：浅色文字/图标
- `dark-content`：深色文字/图标

```ts
Navigation.updateOptions(sceneId, {
  statusBarStyle: 'dark-content',
});
```

### statusBarHidden

```ts
Navigation.updateOptions(sceneId, {
  statusBarHidden: true,
});
```

## TabBar

### tabItem

```ts
withNavigationItem({
  tabItem: {
    title: 'Home',
    icon: Image.resolveAssetSource(require('./images/home.png')),
  },
})(HomeScreen);
```

### updateTabBar / setTabItem

```ts
Navigation.updateTabBar(sceneId, {
  tabBarBackgroundColor: '#FFFFFF',
  tabBarItemSelectedColor: '#4CAF50',
});

Navigation.setTabItem(sceneId, {
  index: 0,
  badge: { hidden: false, text: '99' },
});
```

## 迁移说明（TopBar 移除）

以下字段与 API 已删除：

- 字段：`topBar*`、`titleItem`、`leftBarButtonItem(s)`、`rightBarButtonItem(s)`、`backButtonHidden`、`extendedLayoutIncludesTopBar`
- API：`Navigation.setTitleItem`、`setLeftBarButtonItem(s)`、`setRightBarButtonItem(s)`

推荐迁移方式：

1. 页面内引入统一 RN TopBar 组件。
2. 标题、左右按钮、背景色、透明度、阴影改为 RN 组件本地状态控制。
3. 状态栏样式改用 `statusBarStyle`。
