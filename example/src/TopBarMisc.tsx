import React from 'react'
import { Text, View, TouchableOpacity, ScrollView } from 'react-native'
import { withNavigationItem, InjectedProps } from 'hybrid-navigation'
import styles from './Styles'

export default withNavigationItem({
  titleItem: {
    title: 'TopBar Options',
  },
})(TopBarMisc)

function TopBarMisc({ navigator }: InjectedProps) {
  function noninteractive() {
    navigator.push('Noninteractive')
  }

  function topBarShadowHidden() {
    navigator.push('TopBarShadowHidden')
  }

  function topBarHidden() {
    navigator.push('TopBarHidden')
  }

  function topBarColor() {
    navigator.push('TopBarColor')
  }

  function topBarAlpha() {
    navigator.push('TopBarAlpha')
  }

  function topBarTitleView() {
    navigator.push('TopBarTitleView')
  }

  function statusBarColor() {
    navigator.push('StatusBarColor')
  }

  function statusBarHidden() {
    navigator.push('StatusBarHidden')
  }

  function topBarStyle() {
    navigator.push('TopBarStyle')
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={true}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>About TopBar</Text>
        <TouchableOpacity onPress={topBarShadowHidden} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarShadowHidden</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarHidden</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={topBarColor} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarColor</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={topBarAlpha} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarAlpha</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={topBarTitleView} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarTitleView</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={noninteractive} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Noninteractive</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={statusBarColor} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>StatusBarColor</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={statusBarHidden} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>StatusBarHidden</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={topBarStyle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarStyle</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}
