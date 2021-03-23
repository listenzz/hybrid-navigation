## 1.4.3

- 修正了 peer dependencies，以适应 RN0.64

### iOS specific

- 修复某些设备状态栏没有按声明那样隐藏的问题

## 1.4.2

### Android specific

- 修复 TabBar 可能非正常消失的问题

## 1.4.1

### BreakChanges

- 重新定义了 `Navigator.setInterceptor`

## 1.3.1

### Android specific

- 修复当当前页面类型为 modal 时，`Navigator.current` 未能获取到正确的 navigator 的问题

## 1.3.0

- 添加第二个参数 `inclusive` 到 `popTo`，指示要不要把第一个参数所代表的页面也一起出栈，默认是 `false`，和原来逻辑保持一致。

## 1.2.2

### iOS specific

- 修复切换 TAB 时，生命周期事件触发顺序不正确的问题

- 修复在 UI 层级尚未就绪的情况下，`Navigator.find` 返回 `undefined` 的问题

## 1.2.1

- 修复当存在原生页面时，`routeGroup` 和 `currentRoute` 的崩溃问题

## 1.2.0

- 修复当 definesPresentationContext 开启时，`routeGroup` 和 `currentRoute` 存在的问题

## 1.1.0

- 将 \*/build/ 添加到 .npmignore

- 重新设计了 Navigator 接口

- 优化了 `routeGroup` 和 `currentRoute` 的实现

## 1.0.0

- `Navigator.get` 重命名为 `Navigator.of`
