# RN 页面与原生页面相互跳转和传值

我们为原生和 RN 页面提供了一致的转场和传值方式。

RN 页面如何跳转和传值，我们 [容器与导航](./navigation.md) 一章已经提及，你不需要理会目标页面是原生的还是 RN 的，只要当前页面是 RN 的，处理方式都一样。

## 结果码（resultCode）

在 `present`、`showModal` 或 `pop`/`popTo`/`popToRoot` 返回结果时，会携带一个整型结果码和可选数据。推荐使用库提供的常量：

| 常量 | 含义 |
|------|------|
| `RESULT_OK` | 用户确认、操作成功 |
| `RESULT_CANCEL` | 用户取消、关闭而未确认 |
| `RESULT_BLOCK` | 操作被拦截（如被 `setInterceptor` 拦截）或未真正执行 |

```ts
import Navigation, { RESULT_OK, RESULT_CANCEL, RESULT_BLOCK } from 'hybrid-navigation';

const [resultCode, data] = await navigator.present('Picker');
if (resultCode === RESULT_OK) {
  // 用户选择了内容，使用 data
} else if (resultCode === RESULT_CANCEL) {
  // 用户取消
} else if (resultCode === RESULT_BLOCK) {
  // 跳转被拦截
}
```

仅支持返回可序列化为 JSON 的对象，不能返回函数。

下面我们来说原生页面的跳转和传值方式：

## 创建原生页面

Android 需要继承 `HybridFragment`，具体可以参考 example 项目中 `NativeFragment` 这个类：

```java
// android
public class NativeFragment extends HybridFragment {

}
```

HybridFragment 继承于 `AwesomeFragment`，关于 AwesomeFragment 更多细节，请看 [AndroidNavigation](https://github.com/listenzz/AndroidNavigation) 这个子项目。

iOS 需要继承 `HBDViewController`，具体可以参考 example 项目中 `NativeViewController` 这个类：

```objc
// ios
#import <HybridNavigation/HybridNavigation.h>

@interface NativeViewController : HBDViewController

@end
```

## 注册原生页面

完整 Android/iOS 工程配置请参考 [为原生项目添加 RN 模块](./integration-native.md) 或 [集成到以 RN 为主的项目](./integration-react.md)。以下仅列出与「注册原生模块」相关的片段。

**Android**：在 `MainApplication#onCreate` 中，在 `ReactManager.install(...)` 之后调用：

```java
ReactManager reactManager = ReactManager.get();
reactManager.install(getReactHost()); // 或 getReactNativeHost()，视 RN 版本而定

// 注册原生模块
reactManager.registerNativeModule("NativeModule", NativeFragment.class);
```

**iOS**：在 `AppDelegate` 中，在 `[[HBDReactBridgeManager get] installWithReactHost:...]` 之后调用：

```objc
[[HBDReactBridgeManager get] registerNativeModule:@"NativeModule" forViewController:[NativeViewController class]];
```

> 如果 RN 和原生都注册了同样的模块，即模块名相同，会优先采用 RN 模块。一个应用场景是，如果线上原生模块有严重 BUG，可以通过热更新用 RN 模块临时替换，并指引用户升级版本。

## 原生页面的跳转

首先实例化目标页面

```java
// android
AwesomeFragment fragment = getReactBridgeManager().createFragment("moduleName");
```

```objc
// ios
HBDViewController *vc = [[HBDReactBridgeManager get] controllerWithModuleName:@"moduleName" props:nil options:nil];
```

就这样实例化目标页面，不管这个页面是 RN 的还是原生的。

接下来使用原生方式跳转

```java
// android
StackFragment stackFragment = getStackFragment();
if (stackFragment != null) {
    stackFragment.pushFragment(fragment);
}
```

关于 StackFragment 的更多细节，请看 [AndroidNavigation](https://github.com/listenzz/AndroidNavigation) 这个子项目。

```objc
// ios
[self.navigationController pushViewController:vc animated:YES];
```

> 从原生页面跳转和传值到原生页面，除了上面的方式，你还可以用纯粹原生的方式来实现，就像引入 RN 之前那样

## 原生页面传值和返回结果

### Android

实例化时传值即可，不管这个页面是原生的还是 RN 的

```java
Bundle props = new Bundle();
props.putInt("user_id", 1);
AwesomeFragment fragment = getReactBridgeManager().createFragment("moduleName", props, null);
```

通过以下方式获取其它页面传递过来的值，不管这个页面是原生的还是 RN 的

```java
Bundle props = getProps();
```

通过调用以下方法返回结果给之前的页面，不管这个页面是原生的还是 RN 的

```java
public void setResult(int resultCode, Bundle data);
```

通过重写以下方法来接收结果，不管这个页面是原生的还是 RN 的

```java
public void onFragmentResult(int requestCode, int resultCode, Bundle data) {

}
```

更多细节，请看 [AndroidNavigation](https://github.com/listenzz/AndroidNavigation) 这个子项目。

### iOS

实例化时传值，不管这个页面是原生的还是 RN 的

```objc
NSDictionary *props = @{@"user_id": @1};
HBDViewController *vc = [[HBDReactBridgeManager get] controllerWithModuleName:@"moduleName" props:props options:nil];
```

通过 `self.props` 获取其它页面传递过来的值，不管这个页面是原生的还是 RN 的

通过调用以下方法返回结果给之前的页面，不管这个页面是原生的还是 RN 的

```objc
- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data;
```

通过重写以下方法来接收结果，不管结果来自原生还是 RN 页面

```objc
- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;
```
