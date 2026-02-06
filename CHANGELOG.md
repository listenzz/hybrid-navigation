# Changelog

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
