import React from 'react'
import { TouchableOpacity, Text, View, ScrollView, StatusBar, Platform } from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'
import { withNavigationItem, InjectedProps } from 'hybrid-navigation'
import styles from './Styles'

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
    paddingTop: 16 + StatusBar.currentHeight!,
  },
})

export default withNavigationItem({
  screenBackgroundColor: '#FF0000',
  topBarHidden: true,
  titleItem: {
    title: 'You can not see me',
  },
})(TopBarHidden)

function TopBarHidden({ navigator }: InjectedProps) {
  function topBarHidden() {
    navigator.push('TopBarHidden')
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
    >
      <View style={[styles.container, paddingTop]}>
        <Text style={styles.welcome}>TopBar is hidden</Text>

        <TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarHidden</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}
