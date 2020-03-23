import React, { useState, useEffect } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Image } from 'react-native'

import styles from './Styles'
import {
  RESULT_OK,
  Navigator,
  withNavigationItem,
  useVisibility,
  useResult,
} from 'react-native-navigation-hybrid'

const REQUEST_CODE_1 = 1
const REQUEST_CODE_2 = 2

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
    navigator.isStackRoot().then(root => {
      setIsRoot(root)
    })
  }, [navigator])

  useVisibility(sceneId, visible => {
    if (visible) {
      console.info(`Page Navigation is visible [${sceneId}]`)
      garden.setMenuInteractive(isRoot)
    } else {
      console.info(`Page Navigation is gone [${sceneId}]`)
    }
  })

  useEffect(() => {
    console.info('Page Navigation componentDidMount')
    return () => {
      console.info('Page Navigation componentWillUnmount')
    }
  }, [])

  useEffect(() => {
    navigator.setResult(RESULT_OK, { backId: sceneId })
  }, [navigator, sceneId])

  useResult(sceneId, (requestCode, resultCode, data) => {
    console.info(`requestCode: ${requestCode}`, `resultCode: ${resultCode}`, data)
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
    await printRouteGraph()
  }

  async function printRouteGraph() {
    const graph = await Navigator.routeGraph()
    console.info(graph)
  }

  async function switchTab() {
    await navigator.switchTab(1)
  }

  function handleResult(resultCode, data) {
    if (resultCode === RESULT_OK) {
      setText(data.text)
      setError(undefined)
    } else {
      setText(undefined)
      setError('ACTION CANCEL')
    }
  }

  async function present() {
    const [resultCode, data] = await navigator.presentLayout(
      {
        stack: {
          children: [{ screen: { moduleName: 'Result' } }],
        },
      },
      REQUEST_CODE_1,
    )
    handleResult(resultCode, data)
  }

  async function showModal() {
    const [resultCode, data] = await navigator.showModalLayout(
      {
        screen: {
          moduleName: 'ReactModal',
        },
      },
      REQUEST_CODE_2,
    )
    handleResult(resultCode, data)
  }

  async function showNativeModal() {
    const [resultCode, data] = await navigator.showModal('NativeModal', REQUEST_CODE_2)
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

        <TouchableOpacity onPress={present} activeOpacity={0.2} style={styles.button}>
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
