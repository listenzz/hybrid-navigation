import React, { useState, useEffect } from 'react'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { TouchableOpacity, Text, View, TextInput, Image } from 'react-native'
import styles from './Styles'

import { RESULT_OK, BarStyleLightContent, withNavigationItem, InjectedProps } from 'react-native-navigation-hybrid'

export default withNavigationItem({
  titleItem: {
    title: 'RN result',
  },
  topBarStyle: BarStyleLightContent,
})(Result)

function Result({ navigator, garden }: InjectedProps) {
  const [text, setText] = useState('')
  const [isRoot, setIsRoot] = useState(false)

  useEffect(() => {
    navigator.isStackRoot().then(root => {
      setIsRoot(root)
    })
  }, [navigator])

  useEffect(() => {
    if (isRoot) {
      garden.setLeftBarButtonItem({
        title: 'Cancel',
        icon: Image.resolveAssetSource(require('./images/cancel.png')),
        insetsIOS: { top: -1, left: -8, bottom: 0, right: 8 },
        action: navigator => {
          navigator.dismiss()
        },
      })
    }
  }, [isRoot, garden])

  function popToRoot() {
    navigator.popToRoot()
  }

  function pushToReact() {
    navigator.push('Result')
  }

  async function sendResult() {
    navigator.setResult(RESULT_OK, {
      text: text || '',
    })

    // const graph = await Navigator.routeGraph()
    // const stack = graph[0].children[0].children[0].children
    // const n = Navigator.of(stack[stack.length - 1].sceneId)
    // n.switchTab(1, true)
    // n.pop()
    await navigator.dismiss()

    // let current = await Navigator.current()
    // await current.popToRoot()
    // current = await Navigator.current()
    // await current.switchTab(1, true)
    // current = await Navigator.current()
    // current.push('Navigation')
  }

  function handleTextChanged(text: string) {
    setText(text)
  }

  return (
    <KeyboardAwareScrollView
      style={{ flex: 1 }}
      showsHorizontalScrollIndicator={false}
      contentInsetAdjustmentBehavior="automatic">
      <View style={styles.container}>
        <Text style={styles.welcome}>This's a React Native scene.</Text>

        <TouchableOpacity onPress={pushToReact} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>push to another scene</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={popToRoot} activeOpacity={0.2} style={styles.button} disabled={isRoot}>
          <Text style={isRoot ? styles.buttonTextDisable : styles.buttonText}>pop to home</Text>
        </TouchableOpacity>

        <TextInput
          style={styles.input}
          onChangeText={handleTextChanged}
          value={text}
          placeholder={'enter your text'}
          textAlignVertical="center"
        />

        <TouchableOpacity onPress={sendResult} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>send data back</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAwareScrollView>
  )
}
