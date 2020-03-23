import React from 'react'
import { Text, View, ScrollView, Alert } from 'react-native'
import styles from './Styles'
import { useVisibility, withNavigationItem } from 'react-native-navigation-hybrid'

function Lifecycle({ sceneId }) {
  useVisibility(sceneId, visible => {
    if (visible) {
      Alert.alert(
        'Lifecycle Alert!',
        'componentDidAppear.',
        [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
        {
          cancelable: false,
        },
      )
    } else {
      Alert.alert(
        'Lifecycle Alert!',
        'componentDidDisappear.',
        [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
        { cancelable: false },
      )
    }
  })

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>Extra lifecycle hook</Text>
      </View>
    </ScrollView>
  )
}

export default withNavigationItem({
  titleItem: {
    title: 'Lifecycle Alert',
  },
})(Lifecycle)
