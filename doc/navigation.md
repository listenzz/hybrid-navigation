# 容器与导航

和 react-navigation 一样，内置 Drawer、Tabs、Stack 三种容器，同时支持自定义容器以及导航。导航是指容器如何切换它的子页面，这和容器如何管理它的子页面有很大关系。

## Screen

Screen 不是容器，在 iOS 中，它相当于控制器，在 Android 中，它相当于 Fragment。 在它上面定义了基本的导航能力，为所有容器以及基本页面所共有：

* present

present 是一种模态交互方式，类似于 Android 的 `startActivityForResult`，要求被 present 的页面返回结果给发起 present 的页面。在 iOS 中，present 表现为从底往上弹出界面。

比如 A 页面 `present` 出 B 页面

```javascript
// A.js
this.props.navigator.present('B', 1);
```

B 页面返回结果给 A 页面

```javascript
// B.js
this.props.navigator.setResult(RESULT_OK, { text: 'greeting' });
this.props.navigator.dismiss();
```

A 页面通过实现 `onComponentResult` 方法来接收结果

```javascript
// A.js
onComponentResult(requestCode, resultCode, data) {
  if(requestCode === 1) {
    if(resultCode === RESULT_OK) {
      this.setState({text: data.text || '', error: undefined});
    }
  } else {
    this.setState({text: undefined, error: 'ACTION CANCEL'});
  }
}
```

A 在 present B 时，可以通过第三个参数传值给 B

```javascript
// A.js
this.props.navigator.present('B', 1, {});
```

B 页面可以通过 `this.props` 来获取传递的值

有些时候，比如选择一张照片，我们先要跳到相册列表页面，然后进入某个相册选择相片返回。这也是没有问题的。

A 页面 `present` 出相册列表页面

```javascript
//A.js
this.props.navigator.present('AlbumList', 1);
```

相册列表页面 `push` 到某个相册

```javascript
// AlbumList.js
this.props.navigator.push('Album')
`在相册页面选好相片后返回结果给 A 页面`javascript
// Album.js
this.props.navigator.setResult(RESULT_OK, {uri: 'file://...'})
this.props.navigator.dismiss()
```

在 A 页面接收返回的结果（略）。

* dismiss

关闭 `present` 出来的页面，如果该页面是容器，可以在容器的任何子页面调用此法。

* showModal

将 Component 作为 Modal 显示，用来取代官方的 `Modal` 组件。这也是一种模态交互方式，作用与 present 类似，同样可以通过 `onComponentResult` 来接收结果。不同的是，它比较适合做透明弹窗。在 iOS 底层，它是一个新的 window, 在 Android 底层，它是一个 dialog，所以它的层级较高，不容易被普通页面遮盖。

```javascript
this.props.navigator.showModal('ReactModal', REQUEST_CODE);
```

* hideModal

隐藏作为 Modal 显示的页面，如果 Modal 是一个容器，可以在该容器的任何子页面调用此方法。如果隐藏 modal 的同时希望切换到其它页面，请在调用 `showModal` 的页面的 `onComponentResult` 回调中执行此操作。

```javascript
// ReactModal.js
this.props.navigator.setResult(RESULT_OK, {...});
this.props.navigator.hideModal();
```

* presentLayout

present 的加强版，可以 present 任意结构的页面。第一个参数表示页面结构：

```javascript
// A.js
this.props.navigator.presentLayout(
  {
    stack: {
      screen: { moduleName: 'B' },
    },
  },
  REQUEST_CODE
);
```

以上效果实际等同于：

```javascript
// A.js
this.props.navigator.present('B', 1);
```

也就是说，present 出来的组件，默认会嵌套在 Stack 里面，因为当使用 present 时，嵌套 Stack 是非常常见的操作。

> 同样使用 dismiss 来关闭

* showModalLayout

showModal 的加强版，可以将任意结构的页面作为 Modal 显示

> 同样使用 hideModal 来关闭

## Stack

Stack 以栈的方式管理它的子页面，它支持以下导航操作：

* push

由 A 页面跳转到 B 页面。

```javascript
// A.js
this.props.navigator.push('B');
```

可以通过第二个参数来传值给 B 页面

```javascript
// A.js
this.props.navigator.push('B', {...});
```

B 页面通过 `this.props` 来访问传递过来的值

* pop

返回到前一个页面。比如你由 A 页面 `push` 到 B 页面，现在想返回到 A 页面。

```javascript
// B.js
this.props.navigator.pop();
```

可以通过以下方法来监听用户是否通过点击返回按钮，右滑，或通过代码 pop 来返回前一个页面

```javascript
onComponentBack() {

}
```

* popTo

返回到之前的指定页面。比如你由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回 B 页面。你可以把 B 页面的 `sceneId` 一直传递到 D 页面，然后调用 `popTo('bId')` 返回到 B 页面。

从 B 页面跳转到 C 页面时

```javascript
// B.js
this.props.navigator.push('C', {bId: this.props.sceneId})
`从 C 页面跳到 D 页面时`javascript
// C.js
this.props.navigator.push('D', {bId: this.props.bId})
`现在想从 D 页面 返回到 B 页面`javascript
// D.js
this.props.navigator.popTo(this.props.bId)
```

* popToRoot

返回到 stack 根页面。比如 A 页面是根页面，由 A 页面 `push` 到 B 页面，由 B 页面 `push` 到 C 页面，由 C 页面 `push` 到 D 页面，现在想返回到根部，也就是 A 页面：

```javascript
// D.js
this.props.navigator.popToRoot();
```

pop, popTo, popToRoot 也可以通过 `this.props.setResult(RESULT_OK, {...})`返回结果给目标页面，目标页面通过 `onComponentResult(requestCode, resultCode, data)` 来接受结果。不过由于 push 时并不传递 requestCode, 所以回调时 requestCode 的值总是 0。尽管如此，我们还是可以通过 resultCode 来区分不同情况。

* replace

用指定页面取代当前页面，比如当前页面是 A，想要替换成 B

```javascript
// A.js
this.props.navigator.replace('B');
```

现在 Stack 里没有 A 页面了，被替换成了 B。

* replaceToRoot

移除所有页面，然后把目标页面设置为 Stack 的根页面。

譬如 A 页面是根页面，然后 `push` 到 B、C、D 页面，此时 Stack 里有 A、B、C、D 四个页面，当执行如下操作：

```javascript
// D.js
this.props.navigator.replaceToRoot('E');
```

A、B、C、D 页面被移除，E 页面被设置为 Stack 的根页面。

* isRoot

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

## Tab

* switchTa

切换到指定 tab

* setTabBadge

设置指定 tab 的 badge

## Drawer

* toggleMenu

切换抽屉的开关状态

<a name="navigation-hybrid"></a>

* openMenu

打开抽屉

* closeMenu

关闭抽屉
