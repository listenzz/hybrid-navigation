import React, { useState } from 'react'
import { TouchableOpacity, Text, View, ScrollView } from 'react-native'
import { withNavigationItem, InjectedProps } from 'hybrid-navigation'
import styles from './Styles'

export default withNavigationItem({
  backButtonHidden: true,
  // swipeBackEnabled: false,
  backInteractive: false,
  titleItem: {
    title: 'Noninteractive',
  },
})(Noninteractive)

function Noninteractive({ navigator, garden }: InjectedProps) {
  const [backInteractive, setBackInteractive] = useState(false)

  function handleBackClick() {
    navigator.pop()
  }

  function enableBackInteractive() {
    garden.updateOptions({
      backButtonHidden: false,
      backInteractive: true,
    })
    setBackInteractive(true)
  }

  function disableBackInteractive() {
    garden.updateOptions({
      backButtonHidden: true,
      backInteractive: false,
    })
    setBackInteractive(false)
  }

  let component = null

  if (backInteractive) {
    component = (
      <>
        <Text style={styles.welcome}>Now you can back via any way</Text>
        <TouchableOpacity
          onPress={disableBackInteractive}
          activeOpacity={0.2}
          style={styles.button}>
          <Text style={styles.buttonText}>disable back interactive</Text>
        </TouchableOpacity>
      </>
    )
  } else {
    component = (
      <>
        <Text style={styles.welcome}>Now you can only back via the button below</Text>
        <TouchableOpacity onPress={handleBackClick} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>back</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={enableBackInteractive} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>enable back interactive</Text>
        </TouchableOpacity>
      </>
    )
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>{component}</View>
    </ScrollView>
  )
}
