import React, { useState, useEffect } from 'react'
import { Text, View, ScrollView, Switch } from 'react-native'
import { withNavigationItem, InjectedProps } from 'react-native-navigation-hybrid'
import styles from './Styles'

export default withNavigationItem({
  topBarShadowHidden: true,
  titleItem: {
    title: 'Hide Shadow',
  },
})(TopBarShadowHidden)

function TopBarShadowHidden({ garden }: InjectedProps) {
  const [hidden, setHidden] = useState(true)

  useEffect(() => {
    garden.updateOptions({ topBarShadowHidden: hidden })
  }, [hidden, garden])

  function handleHiddenChange(value: boolean) {
    setHidden(value)
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>
          {hidden ? 'topBar shadow is hidden' : 'topBar shadow is visible'}
        </Text>
      </View>

      <View style={styles.button}>
        <Switch onValueChange={handleHiddenChange} value={hidden} />
      </View>
    </ScrollView>
  )
}
