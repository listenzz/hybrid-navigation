import React from 'react'
import { TouchableOpacity, Text, View } from 'react-native'
import { withNavigationItem, InjectedProps } from 'hybrid-navigation'

import styles from './Styles'
import { getStatusBarHeight } from 'react-native-iphone-x-helper'

export default withNavigationItem({
  statusBarHidden: true,
  topBarHidden: true,
  titleItem: {
    title: 'StatusBar Hidden',
  },
})(StatusBarHidden)

function StatusBarHidden({ navigator, garden }: InjectedProps) {
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
    <View style={[styles.container, { paddingTop: getStatusBarHeight(true) }]}>
      <Text style={styles.welcome}> StatusBar Hidden</Text>
      <TouchableOpacity onPress={showStatusBar} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>show status bar</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={hideStatusBar} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>hide status bar</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={statusBarHidden} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>StatusBarHidden</Text>
      </TouchableOpacity>
    </View>
  )
}
