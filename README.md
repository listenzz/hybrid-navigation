# react-native-navigation-hybrid
A native navigation for React Native which support navigation between native and react side

## Running the Example Project

![navigation-android](./screenshot/navigation-android.gif)

To run the example project, first clone this repo:

```shell
git clone git@github.com:listenzz/react-native-navigation-hybrid.git
cd react-native-navigation-hybrid
```

```shell
npm install
```

```shell
npm start
```

Then, in another CLI window:

To run on iOS: `npm run run:ios`

To run on Android: `npm run run:android`

make sure that you have a  simulator or device when you run andriod

## 集成

在 package.json 中的 dependencies 中添加

```json
"react-native-navigation-hybrid": "0.1.0"
```

### link

```
react-native link
```


## 导航 

### 导航栈
我们先要理解一个叫**导航栈**的概念。在 iOS 中，一个导航栈对应一个 `UINavigationController`；在 Android 中，一个导航栈对应 `FragmentManager` 中的一段 `BackStackEntry`。

### push

由 A 页面跳转到 B 页面。

```javascript
// A.js
this.props.navigator.push('B')
```

### pop

返回到前一个页面。比如你由 A 页面 `push` 到 B 页面，现在想返回到 A 页面。

```javascript
// B.js
this.props.navigator.pop()
```

### popTo

返回到之前的指定页面。比如你由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回 B 页面。你可以把 B 页面的 `sceneId` 一直传递到 D 页面，然后调用 `popTo('bId')` 返回到 B 页面。

从 B 页面跳转到 C 页面时

```javascript
// B.js
this.props.navigator.push('C', {bId: this.props.sceneId})
```

从 C 页面跳到 D 页面时 

```javascript
// C.js
this.props.navigator.push('D', {bId: this.props.bId})
```

现在想从 D 页面 返回到 B 页面

```javascript
// D.js
this.props.navigator.popTo(this.props.bId)
```

### popToRoot

返回到当前导航栈根页面。比如 A 页面是根页面，你由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回到根部，也就是 A 页面。

```javascript
// D.js
this.props.navigator.popToRoot()
```

### isRoot

判断一个页面是否根页面，返回值是一个 Promise.

```javascript
componentWillMount() {
	this.props.navigator.isRoot().then((isRoot) => {
		if(isRoot) {
			this.props.garden.setLeftBarButtonItem({title: '取消', action: 'cancel'});
			this.setState({isRoot});
		}
	})
}
``` 

### replace

用指定页面取代当前页面，比如当前页面是 A，想要替换成 B

```javascript
// A.js
this.props.navigator.replace('B')
```

现在导航栈里没有 A 页面了，被替换成了 B。

> 注意：只能替换位于当前导航栈顶端的页面

### replaceToRoot

把当前导航栈里的所有页面替换成一个页面。譬如 A 页面是根页面，然后 `push` 到 B、C、D 页面，此时导航栈里有 A、B、C、D 四个页面。如果想要重置当前导航栈，把 E 页面设置成根页面。

```javascript
// D.js
this.props.navigator.replaceToRoot('E')
```

现在导航栈里只有 E 页面了。

### present

present 是一种交互模式，类似于 Android 的 `startActivityForResult`，要求后面的页面返回结果给发起 present 的页面。

比如 A 页面 `present` 出 B 页面

```javascript
// A.js
this.navigator.present('B', 1)
```

B 页面返回结果给 A 页面 

```javascript
// B.js
this.navigator.setResult(RESULT_OK, {text: 'greeting'})
this.navigator.dismiss()
```

A 页面实现 `onComponentResult` 来接收这个结果

```javascript
// A.js
onComponentResult(requestCode, resultCode, data) {
	if(requestCode === 1) { 
		if(resultCode === RESULT_OK) {
			this.setState({text: data.text || '', error: undefined});
		} else {
			this.setState({text: undefined, error: 'ACTION CANCEL'});
		}
	}
}
```

有些时候，比如选择一张照片，我们先要跳到相册列表页面，然后进入某个相册选择相片返回。这也是没有问题的。

A 页面 `present` 出相册列表页面

```javascript
//A.js
this.props.navigator.present('AlbumList', 1)
```

相册列表页面 `push` 到某个相册

```javascript
// AlbumList.js
this.props.navigator.push('Album')
```

在相册页面选好相片后返回结果给 A 页面

```javascript
// Album.js
this.props.navigator.setResult(RESULT_OK, {uri: 'file://...'})
this.props.navigator.dismiss()
```

在 A 页面接收返回的结果（略）。

### dismiss

关闭 `present` 出来的整个导航栈中的页面，可以在当前导航栈中的任意页面调用。

### 传值
由一个页面跳转到另一个页面时，`push`, `present`, `replace`, `replaceToRoot` 是可以通过 props 这个参数来传值的，但只支持可以序列化成 json 的对象。以下是这些方法的完整签名：

```javascript
push(moduleName, props={}, options={}, animated = true)

replace(moduleName, props={}, options={})

replaceToRoot(moduleName, props={}, options={})

present(moduleName, requestCode,  props={}, options={}, animated = true)
```

options 这个参数的作用我们会在其它地方讲解。

### 导航栈边界

比如 A `push` B `push` C `push` D `present` E `push` F

现在存在两个导航栈，A、B、C、D 在一个栈，E 和 F 在另一栈，它们分界就是因为 E 是 D `present` 出来的。

`popTo`, `popToRoot`, `replaceToRoot`, `isRoot` 都是有边界的

在 F 调用 `popTo` 是不能返回 A、B、C、D 中的任何页面的，因为 F 和它们不在同一个栈。

在 F 调用 `popToRoot` 只能返回到 E 页面，因为 E 就是 F 所在栈的根部。

同理，在 F 调用 `replaceToRoot` 只能替换到 E 页面。

在 A 或 E 中调用 `isRoot` 会返回 `true`，其它页面返回 `false`

## 定制顶部导航栏

在 iOS 中，导航栏是指 statusBar，UINavigationBar，在 Android 中，导航栏是指 statusBar，ToolBar。

一个 APP 中的风格通常是一致的，使用 `Garden` 中的静态方法，可以全局设置 APP 的主题。

### 设置全局主题

- setTopBarStyle

如果不设置 topBarStyle ，在 iOS 中，导航栏默认是白底黑字，在 Android 中，导航栏默认是黑（蓝）底白字。

这个方法一共有两个常量可选 `TOP_BAR_STYLE_LIGHT_CONTENT` 和 `TOP_BAR_STYLE_DARK_CONTENT`。








