import React, { useState, useEffect, useCallback } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Image, TextInput } from 'react-native'

import styles from './Styles'
import Navigation, {
  RESULT_OK,
  withNavigationItem,
  useVisible,
  NavigationProps,
  useVisibleEffect,
} from 'hybrid-navigation'
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context'
import { KeyboardInsetsView } from 'react-native-keyboard-insets'

export default withNavigationItem({
  //topBarStyle: 'light-content',
  //topBarColor: '#666666',
  //topBarTintColor: '#ffffff',
  //titleTextColor: '#ffffff',

  titleItem: {
    title: 'RN navigation',
  },

  tabItem: {
    title: 'Navigation',
    icon: Image.resolveAssetSource(require('./images/navigation.png')),
  },
})(NavigationScreen)

interface Props extends NavigationProps {
  popToId?: string
}

function NavigationScreen({ navigator, sceneId, popToId }: Props) {
  const [text, setText] = useState<string>()
  const [error, setError] = useState<string>()
  const [isRoot, setIsRoot] = useState(false)

  useEffect(() => {
    navigator.isStackRoot().then(root => {
      setIsRoot(root)
    })
  }, [navigator])

  useVisibleEffect(
    useCallback(() => {
      console.info(`Page Navigation is visible [${sceneId}]`)
      return () => console.info(`Page Navigation is invisible [${sceneId}]`)
    }, [sceneId]),
  )

  const visible = useVisible()
  useEffect(() => {
    Navigation.setMenuInteractive(sceneId, isRoot && visible)
  }, [visible, isRoot, sceneId])

  useEffect(() => {
    console.info(`Page Navigation componentDidMount [${sceneId}]`)
    return () => {
      console.info(`Page Navigation componentWillUnmount [${sceneId}]`)
    }
  }, [sceneId])

  useEffect(() => {
    navigator.setResult(RESULT_OK, { backId: sceneId })
  }, [navigator, sceneId])

  async function push() {
    let props: Partial<Props> = {}
    if (!isRoot) {
      if (popToId !== undefined) {
        props.popToId = popToId
      } else {
        props.popToId = sceneId
      }
    }
    const [_, data] = await navigator.push('Navigation', props)
    if (data) {
      setText(data.backId || undefined)
    }
  }

  async function pop() {
    await navigator.pop()
  }

  async function popTo() {
    if (popToId) {
      await navigator.popTo(popToId)
    }
  }

  async function popToRoot() {
    await navigator.popToRoot()
  }

  async function redirectTo() {
    if (popToId !== undefined) {
      await navigator.redirectTo('Navigation', {
        popToId,
      })
    } else {
      await navigator.redirectTo('Navigation')
    }
  }

  async function printRouteGraph() {
    const graph = await Navigation.routeGraph()
    console.log(JSON.stringify(graph, null, 2))
    const route = await Navigation.currentRoute()
    console.log(JSON.stringify(route, null, 2))
  }

  async function switchTab() {
    await navigator.switchTab(1)
  }

  function handleResult(resultCode: number, data: { text?: string }) {
    console.log(`Navigation result [${sceneId}]`, resultCode, data)
    if (resultCode === RESULT_OK) {
      setText(data?.text)
      setError(undefined)
    } else {
      setText(undefined)
      setError('ACTION CANCEL')
    }
  }

  async function present() {
    const [resultCode, data] = await navigator.present<{ text?: string }>('Result')
    handleResult(resultCode, data)
  }

  async function showModal() {
    const [resultCode, data] = await navigator.showModal<{ text?: string }>('ReactModal')
    handleResult(resultCode, data)
  }

  function renderResult() {
    if (text === undefined) {
      return null
    }
    return <Text style={styles.result}>received text：{text}</Text>
  }

  function renderError() {
    if (error === undefined) {
      return null
    }
    return <Text style={styles.result}>{error}</Text>
  }

  const [input, setInput] = useState<string>()

  function handleTextChanged(txt: string) {
    setInput(txt)
  }

  return (
    <SafeAreaProvider>
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
        <View style={styles.container}>
          <Text style={styles.welcome}>This's a React Native scene.</Text>

          <TouchableOpacity onPress={push} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>push</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={pop}
            activeOpacity={0.2}
            style={styles.button}
            disabled={isRoot}>
            <Text style={isRoot ? styles.buttonTextDisable : styles.buttonText}>pop</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={popTo}
            activeOpacity={0.2}
            style={styles.button}
            disabled={popToId === undefined}>
            <Text style={popToId === undefined ? styles.buttonTextDisable : styles.buttonText}>
              popTo first
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={popToRoot}
            activeOpacity={0.2}
            style={styles.button}
            disabled={isRoot}>
            <Text style={isRoot ? styles.buttonTextDisable : styles.buttonText}>popToRoot</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={redirectTo} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>redirectTo</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={present} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>present</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={switchTab} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>switch to tab 'Options'</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>show modal</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={printRouteGraph} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>printRouteGraph</Text>
          </TouchableOpacity>
          {renderResult()}
          {renderError()}
        </View>
      </ScrollView>
      <KeyboardInsetsView extraHeight={16} style={styles.keyboard}>
        <TextInput
          style={styles.input2}
          onChangeText={handleTextChanged}
          value={input}
          placeholder={'test keyboard instes'}
          textAlignVertical="center"
        />
        <SafeAreaView edges={['bottom']} />
      </KeyboardInsetsView>
    </SafeAreaProvider>
  )
}
