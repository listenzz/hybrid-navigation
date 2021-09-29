import React, { useState, useEffect } from 'react'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { TouchableOpacity, Text, View, TextInput, Image } from 'react-native'
import styles from './Styles'

import { RESULT_OK, BarStyleLightContent, withNavigationItem, InjectedProps, Navigator } from 'hybrid-navigation'

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
    await navigator.dismiss()
  }

  function handleTextChanged(text: string) {
    setText(text)
  }

  async function present() {
    await navigator.present('Result')
  }

  async function showModal() {
    await navigator.showModal('ReactModal')
  }

  async function printRouteGraph() {
    const graph = await Navigator.routeGraph()
    console.log(JSON.stringify(graph, null, 2))
    const route = await Navigator.currentRoute()
    console.log(JSON.stringify(route, null, 2))
  }

  return (
    <KeyboardAwareScrollView
      style={{ flex: 1 }}
      showsHorizontalScrollIndicator={false}
      contentInsetAdjustmentBehavior="automatic"
    >
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

        <TouchableOpacity onPress={present} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>present</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>showModal</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={printRouteGraph} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>printRouteGraph</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAwareScrollView>
  )
}
