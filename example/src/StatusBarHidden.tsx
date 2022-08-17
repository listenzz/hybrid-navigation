import React from 'react'
import { TouchableOpacity, Text, View } from 'react-native'
import Navigation, { withNavigationItem, NavigationProps, statusBarHeight } from 'hybrid-navigation'

import styles from './Styles'

export default withNavigationItem({
  statusBarHidden: true,
  topBarHidden: true,
  titleItem: {
    title: 'StatusBar Hidden',
  },
})(StatusBarHidden)

function StatusBarHidden({ navigator, sceneId }: NavigationProps) {
  function statusBarHidden() {
    navigator.push('StatusBarHidden')
  }

  function showStatusBar() {
    Navigation.updateOptions(sceneId, { statusBarHidden: false })
  }

  function hideStatusBar() {
    Navigation.updateOptions(sceneId, { statusBarHidden: true })
  }

  return (
    <View style={[styles.container, { paddingTop: statusBarHeight() }]}>
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
