import React from 'react'
import { TouchableOpacity, Text, View, ScrollView } from 'react-native'
import { withNavigationItem, InjectedProps, Garden } from 'hybrid-navigation'
import styles from './Styles'

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
    <ScrollView>
      <View style={[styles.container, { paddingTop: Garden.statusBarHeight() }]}>
        <Text style={styles.welcome}>TopBar is hidden</Text>
        <TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarHidden</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}
