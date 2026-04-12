# Changelog

## 4.0.0

### 破坏性变更

- 移除原生 TopBar 能力，iOS `UINavigationBar` 改为始终隐藏；页面顶部 UI 需在 RN 侧实现。
- `Navigation` API 删除：`setTitleItem`、`setLeftBarButtonItem`、`setRightBarButtonItem`、`setLeftBarButtonItems`、`setRightBarButtonItems`、`setBarButtonClickEventListener`。
- `NavigationItem` 删除字段：`titleItem`、`leftBarButtonItem(s)`、`rightBarButtonItem(s)`、`topBarHidden`、`backButtonHidden`、`extendedLayoutIncludesTopBar`、`passThroughTouches`、`forceTransparentDialogWindow`。
- `NavigationOption` / `DefaultOptions` 不再支持 `topBar*` 系列配置；状态栏样式统一使用 `statusBarStyle`。
- `TabItem.hideTabBarWhenPush` 移除，push 场景不再通过该字段控制 TabBar 显隐。
- Android 不再读取 `swipeBackEnabledAndroid`、`scrimAlphaAndroid`、`fitsOpaqueNavigationBarAndroid` 全局样式选项。
- 移除 Android/iOS 字体图标 URI（`font://...`）支持。
- Android 内联 `AndroidNavigation` 源码并移除 Maven 依赖。

### 修复

- 修复 `stack > tabs > screen` 层级下 `isStackRoot` 判断错误（Android / iOS）。
- 修复该层级下 `tabBarItem` 更新不生效（iOS）。
- iOS Tab 容器将状态栏样式委托给当前选中页面，切换 Tab 后状态栏样式可正确更新。
- iOS `dismiss` 改为从 modal host 执行关闭，并在返回后恢复页面方向，减少横竖屏错乱。

### 优化

- iOS 横竖屏切换流程重构（iOS 16+ geometry update 前先刷新支持方向并结束编辑），降低旋转异常。
- iOS 强制横屏页面禁用交互式返回手势，减少转场冲突。
- React 页面改为占满容器，由 RN 统一处理安全区；Android 在含 TabBar 场景向 RN 注入 `tabBarInset`。
- 移除 `UIScrollView` 全局 hook（`didMoveToWindow` swizzle），减少对系统行为的侵入。

### 文档与示例

- 文档对齐 v4：样式与集成指南改为 RN TopBar 方案，并补充迁移说明。
- README/文档更新版本矩阵（3.x 对应 RN >= 0.83），示例工程更新到 RN 0.84 / Node >= 20。
- 示例项目移除原生 TopBar 示例页并调整启动流程（Android 迁移到 `core-splashscreen`）。

## 3.1.2

### iOS

#### Fixed

- 修复 iOS 26 上 `UIScrollView` 边缘模糊效果异常。
- 修复 TabBar dot badge 的绘制位置偏差。
- 修复首次替换 TabBar 图标时的颜色闪动问题。
- 加固 dismiss 结果分发的边界处理，降低异常时序下的结果丢失风险。
- 修复布局级 `present` / `modal` 的结果回传问题。
- 修复转场结束后 TabBar 隐藏状态恢复不正确的问题。
- 支持横屏页面的交互式返回转场。
- 修复 `redirectTo` 在目标控制器失效时的崩溃。
- 修复侧滑返回时 TabBar 首次闪现问题。
- 统一横竖屏方向控制，并修复旋转过程中的黑色方块问题。

## 3.1.1

### 修复

- **iOS**：全局 topBarHidden 时不使用假导航栏
- **iOS**：移除状态栏高度校正，局部隐藏或透明 topBar 时保证页面到顶

## 3.1.0

### 新功能

- **支持全局 topBarHidden**：可通过全局配置隐藏顶部导航栏

### 修复

- **iOS**：局部隐藏或透明 topBar 时，修正 SafeAreaInsets 顶部为状态栏高度
- **iOS**：仅全局 topBarHidden 时直接隐藏 UINavigationBar，局部通过 alpha 处理
- **iOS**：TabBar 场景下使用 tabBar 高度作为 React 视图底部 inset
- **iOS**：假导航栏过渡时补偿 SafeAreaInsets
- **iOS**：修复 TopBarStyle 页面在交互 pop 时边衬区失效的问题
- **Android**：强制横屏时禁用转场动画
- 修复可见性回调可能不触发的问题

### 优化

- 优化屏幕旋转相关逻辑
