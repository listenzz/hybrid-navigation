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
  displayCutoutWhenLandscapeAndroid?: boolean;
  homeIndicatorAutoHiddenIOS?: boolean;
  backInteractive?: boolean;
}
```

### NavigationItem

```ts
interface NavigationItem extends NavigationOption {
  animatedTransition?: boolean;
  forceScreenLandscape?: boolean;
  tabItem?: {
    title: string;
    icon?: { uri: string; scale?: number; height?: number; width?: number };
    unselectedIcon?: { uri: string; scale?: number; height?: number; width?: number };
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

## 迁移说明（passThroughTouches 移除）

`passThroughTouches` 已从 `NavigationItem` 中移除，且不再提供兼容占位行为（no-op）。

## 迁移说明（返回交互）

页面返回交互统一通过 `backInteractive` 控制；`swipeBackEnabledAndroid`、`scrimAlphaAndroid`、`swipeBackEnabled` 不再作为公开配置项提供。
