# Changelog

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
