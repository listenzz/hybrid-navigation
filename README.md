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

- 导航栈

	我们先要理解一个叫**导航栈**的概念。在 iOS 中，一个导航栈对应一个 `UINavigationController`；在 Android 中，一个导航栈对应 `FragmentManager` 中的一段 `BackStackEntry`。

- push

	由 A 页面跳转到 B 页面。
	
	```javascript
    // A.js
    this.props.navigator.push('B')
	```

- pop

	返回到前一个页面。比如你由 A 页面 `push` 到 B 页面，现在想返回到 A 页面。
	
	```javascript
    // B.js
    this.props.navigator.pop()
	```

- popTo

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
	
- popToRoot

	返回到当前导航栈根页面。比如 A 页面是根页面，你由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回到根部，也就是 A 页面。
	
	```javascript
    // D.js
    this.props.navigator.popToRoot()
	```

- isRoot

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

- replace

	用指定页面取代当前页面，比如当前页面是 A，想要替换成 B
	
	```javascript
    // A.js
    this.props.navigator.replace('B')
	```
	
	现在导航栈里没有 A 页面了，被替换成了 B。
	
	> 注意：只能替换位于当前导航栈顶端的页面
	
- replaceToRoot

	把当前导航栈里的所有页面替换成一个页面。譬如 A 页面是根页面，然后 `push` 到 B、C、D 页面，此时导航栈里有 A、B、C、D 四个页面。如果想要重置当前导航栈，把 E 页面设置成根页面。
	
	```javascript
    // D.js
    this.props.navigator.replaceToRoot('E')
	```
	
	现在导航栈里只有 E 页面了。

- present

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
	
- dismiss

	关闭 `present` 出来的整个导航栈中的页面，可以在当前导航栈中的任意页面调用。
	
- 传值

	由一个页面跳转到另一个页面时，`push`, `present`, `replace`, `replaceToRoot` 是可以通过 props 这个参数来传值的，但只支持可以序列化成 json 的对象。以下是这些方法的完整签名：
	
	```javascript
    push(moduleName, props={}, options={}, animated = true)
    	
    replace(moduleName, props={}, options={})
    	
    replaceToRoot(moduleName, props={}, options={})
    	
    present(moduleName, requestCode,  props={}, options={}, animated = true)
	```
	
	options 这个参数的作用我们会在其它地方讲解。
	
- 导航栈边界

	比如 A `push` B `push` C `push` D `present` E `push` F
	
	现在存在两个导航栈，A、B、C、D 在一个栈，E 和 F 在另一栈，它们分界就是因为 E 是 D `present` 出来的。
	
	`popTo`, `popToRoot`, `replaceToRoot`, `isRoot` 都是有边界的
	
	在 F 调用 `popTo` 是不能返回 A、B、C、D 中的任何页面的，因为 F 和它们不在同一个栈。
	
	在 F 调用 `popToRoot` 只能返回到 E 页面，因为 E 就是 F 所在栈的根部。
	
	同理，在 F 调用 `replaceToRoot` 只能替换到 E 页面。
	
	在 A 或 E 中调用 `isRoot` 会返回 `true`，其它页面返回 `false`

## 定制顶部导航栏

在 iOS 中，导航栏是指 statusBar，UINavigationBar，在 Android 中，导航栏是指 statusBar，ToolBar。

一个 APP 中的风格通常是一致的，使用 `Garden.setStyle` 可以全局设置 APP 的主题。

### 设置全局主题

setStyle 接受一个对象为参数，可配置字段如下：

```javascript
{
    topBarStyle: String // 状态栏和导航栏前景色，可选值有 light-content 和 dark-content
    topBarBackgroundColor: String // 顶部导航栏背景颜色
    statusBarColor: String // 状态栏背景色，仅对 Android 21 以上版本生效
    hideBackTitle: Bool // 是否隐藏返回按钮旁边的文字，默认是 false, 仅对 iOS 生效
    elevation: Number // 导航栏阴影高度， 仅对 Android 21 以上版本生效，默认值为 8 ，单位是 dp
    shadowImage: Object // 导航栏阴影图片，仅对 iOS 和 较低版本的 Android 生效 
    backIcon: Object // 返回按钮图标，需要传递一个带有 uri 和其它字段的对象
    topBarTintColor: String // 顶部导航栏标题和按钮的颜色
    titleTextColor: String // 顶部导航栏标题颜色
    titleTextSize: Int // 顶部导航栏标题字体大小，单位是 dp(pt)
    titleAlignment: String // 顶部导航栏标题的位置，有 left 和 center 两个值可选，默认是 left
    barButtonItemTintColor: String // 顶部导航栏按钮颜色
    barButtonItemTextSize: Int // 顶部导航栏按钮字体大小，单位是 dp(pt)
}
```

> 全局设置主题，有些样式需要重新运行原生应用才能看到效果。

- topBarStyle

	可选，导航栏和状态栏前景色，在 iOS 中，默认是白底黑字，在 Android 中，默认是黑底白字。
	
	这个字段一共有两个常量可选： `dark-content` 和 `light-content`，在 Android-23 效果如下。
	
	![topbar-default](./screenshot/topbar-default.png)

- topBarBackgroundColor

	可选，导航栏（UINavigationBar | ToolBar）背景颜色。如果不设置，将根据 topBarStyle 来计算，如果 topBarStyle 的值是 dark-content，那么 topBarBackgroundColor 的值是白色，否则是黑色。
	
	> 注意，可配置的颜色仅支持 #AARRGGBB 或者 #RRGGBB 格式的字符

- statusBarColor

	可选，仅对 Android 21 版本生效。如果不设置，默认取 `topBarBackgroundColor` 的值

- hideBackTitle

	可选，仅对 iOS 生效，用来决定是否隐藏返回按钮旁边的文字，即前一个页面的标题
	
- elevation

	可选，导航栏阴影高度，仅对 Android 21 以上版本生效，默认值为 8 ，单位是 dp
	
- shadowImage

	导航栏阴影图片，暂不支持

- backIcon

	可选，配置返回按钮的图标。如果不配置，则采用平台默认的图标。配置方式如下

    ```javascript
    // index.js
    	
    import { Image } from 'react-native'
    import { Garden } from 'react-native-navigation-hybrid'
    	
    Garden.setStyle({
        backIcon: Image.resolveAssetSource(require('./ic_back.png')),
    })
	
    ```

	> 支持 vector-font

- topBarTintColor

	可选，顶部导航栏标题和按钮的颜色。如果不设置，将根据 topBarStyle 来计算，如果 topBarStyle 的值是 dark-content，那么 topBarTintColor 的值是黑色，否则是白色。

- titleTextColor

	可选，顶部导航栏标题的颜色。如果不设置，取 topBarTintColor 的值。

- titleTextSize

	可选，顶部导航栏标题的字体大小，单位是 dp(pt)，默认是 17 dp(pt)。

- titleAlignment

	可选，顶部导航栏标题的位置，仅对 Android 生效，有 left 和 center 两个值可选，默认是 left

- barButtonItemTintColor

	可选，顶部导航栏按钮的颜色。如果不设置， 取 topBarTintColor 的值。

- barButtonItemTextSize

	可选，顶部导航栏按钮的字体大小，单位是 dp(pt)，默认是 15 dp(pt)

### 静态配置页面

每个页面的标题、按钮，通常是固定的，我们可以通过静态的方式来配置。

我们需要在页面实现 `navigationItem` 这个静态字段，完整的可配置项如下：

```javascript
class Screen extends Component {

    static navigationItem = {
        hidesBackButton: true,     // 当前页面是否隐藏返回按钮
        titleItem: {               // 导航栏标题
            tilte: '这是标题', 
        },
        	
        leftBarButtonItem: {      // 导航栏左侧按钮
            title: '按钮',
            icon: Image.resolveAssetSource(require('./ic_settings.png')),
            action: 'left-button-click',
            enabled: true,
        },
        	
        rightBarButtonItem: {     // 导航栏左侧按钮
            // 可配置项同 leftBarButtonItem
        }
    }
    	
    onBarButtonItemClick(action) {
    	// do something
    }
	
}
```

- hidesBackButton

	可选，用来控制是否隐藏当前页面的返回按钮。一旦设置为 true，在 iOS 中将不能通过手势右滑返回，在 Android 中将不能通过返回键（物理）退出当前页面。
	
- titleItem

	可选，设置页面标题

- leftBarButtonItem

	可选，设置导航栏左侧按钮。通常用在根页面，一旦设置了 leftBarButtonItem，将取代返回按钮，在 iOS 中将不能通过手势右滑返回，但在 Andriod 中仍可以通过物理键返回。
	
	title 是按钮标题，icon 是按钮图标，两者设置其一则可，如果同时设置，则只会显示图标。
	
	action 是个字符串，用来标识用户在当前页面触发的是哪个行为，当用户点击按钮时，这个值会被作为参数传递到实例方法 `onBarButtonItemClick` 。
	
	enabled 是个布尔值，可选，用来标识按钮是否可以点击，默认是 true。

- rightBarButtonItem

	可选，导航栏右侧按钮。不会对页面有任何副作用。
	
### 动态配置页面

有时，需要根据业务状态来动态改变导航栏中的项目。比如 rightBarButtonItem 是否可以点击，就是个很好的例子。

动态配置页面有两种方式，一种是页面跳转时，由前一个页面决定后一个页面的配置。另一种是当前页面根据应用状态来自行改变。

#### 传值配置

譬如以下是 B 页面的静态配置 

```javascript
// B.js
class B extends Component {
    static navigationItem = {
        titleItem: {               
            tilte: 'B 的标题', 
        },
        rightBarButtonItem: {      
            title: '按钮',
            action: 'left-button-click',
        },
    }
    onBarButtonItemClick(action) {
        // do something
    }
}
```

正常情况下，B 的导航栏标题是 *B 的标题*，导航栏右侧按钮的标题是 *按钮*。

从 A 页面跳转到 B 页面时，我们可以改变 B 页面中的静态设置

```javascript
// A.js

this.props.navigator.push('B', {/*props*/}, {
    titleItem: {
        title: '来自 A 的标题'
    },
    rightBarButtonItem: {
        title: '点我'
    }
})

```

那么，如果 B 页面是从 A 跳过来的，那么 B 的导航栏标题就会变成 *来自 A 的标题* ，导航栏右侧按钮的标题就会变成 *点我*。


> 注意：更改是增量的，你不需要配置一个完整的 item。

#### 动态配置

Garden 提供了一些实例方法，来帮助我们动态改变这些项目。

- setTitleItem

	更改标题
    
    ```javascript
    this.props.garden.setTitleItem({
        title: '新的标题'
    })
    ```

- setLeftBarButtonItem

	更改左侧按钮

- setRightBarButtonItem

	更改右侧按钮
	
    ```javascript
    this.props.garden.setRightBarButtonItem({
        enabled: false
    })
    ```

> 注意：更改是增量的，你不需要配置一个完整的 item。









