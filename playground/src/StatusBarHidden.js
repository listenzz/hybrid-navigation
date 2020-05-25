import React from 'react'
import { TouchableOpacity, Text, View, ScrollView, StatusBar, Platform } from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'
import { withNavigationItem } from 'react-native-navigation-hybrid'

import styles from './Styles'

function ifKitKat(obj1 = {}, obj2 = {}) {
  return Platform.Version > 18 ? obj1 : obj2
}

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 16 + 44,
      },
      {
        paddingTop: 16 + 20,
      },
    ),
  },
  android: {
    ...ifKitKat(
      {
        paddingTop: 16 + StatusBar.currentHeight,
      },
      {
        paddingTop: 16,
      },
    ),
  },
})

export default withNavigationItem({
  statusBarColorAndroid: '#00FF00',
  statusBarHidden: true,
  topBarHidden: true,
  titleItem: {
    title: 'StatusBar Hidden',
  },
})(StatusBarHidden)

function StatusBarHidden({ navigator, garden }) {
  function statusBarHidden() {
    navigator.push('StatusBarHidden')
  }

  function showStatusBar() {
    garden.updateOptions({ statusBarHidden: false })
  }

  function hideStatusBar() {
    garden.updateOptions({ statusBarHidden: true })
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <Text style={[styles.welcome, paddingTop]}> StatusBar Hidden</Text>
      <TouchableOpacity onPress={showStatusBar} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>show status bar</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={hideStatusBar} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>hide status bar</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={statusBarHidden} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>StatusBarHidden</Text>
      </TouchableOpacity>
    </ScrollView>
  )
}
