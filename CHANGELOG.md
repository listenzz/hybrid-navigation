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
