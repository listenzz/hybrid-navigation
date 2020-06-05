import React, { useState, useEffect, useCallback } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Image } from 'react-native'

import styles from './Styles'
import {
  RESULT_OK,
  Navigator,
  withNavigationItem,
  useVisibleEffect,
  useVisible,
  useResult,
} from 'react-native-navigation-hybrid'

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
    hideTabBarWhenPush: true,
  },
})(Navigation)

function Navigation({ navigator, garden, sceneId, popToId }) {
  const [text, setText] = useState(undefined)
  const [error, setError] = useState(undefined)
  const [isRoot, setIsRoot] = useState(false)

  useEffect(() => {
    navigator.isStackRoot().then((root) => {
      setIsRoot(root)
    })
  }, [navigator])

  const visibleCallback = useCallback(() => {
    console.info(`Page Navigation is visible [${sceneId}]`)
    return () => {
      console.info(`Page Navigation is gone [${sceneId}]`)
    }
  }, [sceneId])

  useVisibleEffect(sceneId, visibleCallback)

  const visible = useVisible(sceneId)

  useEffect(() => {
    garden.setMenuInteractive(isRoot && visible)
  }, [visible, isRoot, garden])

  useEffect(() => {
    console.info(`Page Navigation componentDidMount [${sceneId}]`)
    return () => {
      console.info(`Page Navigation componentWillUnmount [${sceneId}]`)
    }
  }, [sceneId])

  useEffect(() => {
    navigator.setResult(RESULT_OK, { backId: sceneId })
  }, [navigator, sceneId])

  useResult(sceneId, (requestCode, resultCode, data) => {
    console.info(
      `requestCode: ${requestCode}`,
      `resultCode: ${resultCode}`,
      data,
      `sceneId:${sceneId}`,
    )
  })

  async function push() {
    let props = {}
    if (!isRoot) {
      if (popToId !== undefined) {
        props.popToId = popToId
      } else {
        props.popToId = sceneId
      }
    }
    const [_, data] = await navigator.push('Navigation', props)
    console.log('===================>>>>>>>>>', sceneId, data)
    if (data) {
      setText(data.backId || undefined)
    }
  }

  async function pop() {
    await navigator.pop()
    //await printRouteGraph()
  }

  async function popTo() {
    await navigator.popTo(popToId)
    //await printRouteGraph()
  }

  async function popToRoot() {
    await navigator.popToRoot()
    // await printRouteGraph()
  }

  async function redirectTo() {
    if (popToId !== undefined) {
      await navigator.redirectTo('Navigation', {
        popToId,
      })
    } else {
      await navigator.redirectTo('Navigation')
    }
    // await printRouteGraph()
  }

  async function printRouteGraph() {
    const graph = await Navigator.routeGraph()
    console.info(graph)
  }

  async function switchTab() {
    await navigator.switchTab(1)
  }

  function handleResult(resultCode, data) {
    console.log(resultCode, data)
    if (resultCode === RESULT_OK) {
      setText(data.text)
      setError(undefined)
    } else {
      setText(undefined)
      setError('ACTION CANCEL')
    }
  }

  function test() {
    // showModal()
    present()
  }

  async function present() {
    const [resultCode, data] = await navigator.present('Result')
    handleResult(resultCode, data)
  }

  async function showModal() {
    const [resultCode, data] = await navigator.showModal('ReactModal')
    handleResult(resultCode, data)
  }

  async function showNativeModal() {
    const [resultCode, data] = await navigator.showModal('NativeModal')
    handleResult(resultCode, data)
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>This's a React Native scene.</Text>

        <TouchableOpacity onPress={push} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>push</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={pop} activeOpacity={0.2} style={styles.button} disabled={isRoot}>
          <Text style={isRoot ? styles.buttonTextDisable : styles.buttonText}>pop</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={popTo}
          activeOpacity={0.2}
          style={styles.button}
          disabled={popToId === undefined}>
          <Text style={popToId === undefined ? styles.buttonTextDisable : styles.buttonText}>
            popTo last but one
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

        <TouchableOpacity onPress={test} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>present</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={switchTab} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>switch to tab 'Options'</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>show react modal</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={showNativeModal} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>show native modal</Text>
        </TouchableOpacity>

        {text !== undefined && <Text style={styles.result}>received text：{text}</Text>}
        {error !== undefined && <Text style={styles.result}>{error}</Text>}
      </View>
    </ScrollView>
  )
}
