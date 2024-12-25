import React from 'react'
import { TouchableOpacity, Text, View, ScrollView } from 'react-native'
import { useNavigator } from 'hybrid-navigation'
import styles from './Styles'
import { withNavigationItem } from 'hybrid-navigation'

export default withNavigationItem({
  topBarHidden: true,
  backInteractive: false,
  forceScreenLandscape: true,
  animatedTransition: false,
  homeIndicatorAutoHiddenIOS: true,

  titleItem: {
    title: 'Landscape',
  },
})(Landscape)

function Landscape() {
  const navigator = useNavigator()

  const back = () => {
    navigator.pop()
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={[styles.container, { paddingTop: 64 }]}>
        <TouchableOpacity onPress={back} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Back</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}
