import React, { useCallback } from 'react'
import { TouchableOpacity, Text, View, StatusBar, Platform } from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'
import { toolbarHeight, useVisibleEffect, InjectedProps } from 'react-native-navigation-hybrid'

import styles from './Styles'

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 16 + 88,
      },
      {
        paddingTop: 16 + 64,
      },
    ),
  },
  android: {
    paddingTop: 16 + StatusBar.currentHeight! + toolbarHeight,
  },
})

export default function Menu({ navigator, sceneId }: InjectedProps) {
  const push = useCallback(() => {
    navigator.closeMenu()
    navigator.push('OneNative')
  }, [navigator])

  function pushToRedux() {
    navigator.closeMenu()
    navigator.push('ReduxCounter')
  }

  function pushToToast() {
    navigator.closeMenu()
    navigator.push('Toast')
  }

  const visibleCallback = useCallback(() => {
    console.log(`Menu is visible`)
    return () => {
      console.log(`Menu is gone`)
    }
  }, [])

  useVisibleEffect(sceneId, visibleCallback)

  return (
    <View style={[styles.container, paddingTop]}>
      <Text style={styles.welcome}>This's a React Native Menu.</Text>

      <TouchableOpacity onPress={push} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>push to native</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={pushToRedux} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>Redux Counter</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={pushToToast} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>Toast</Text>
      </TouchableOpacity>
    </View>
  )
}
