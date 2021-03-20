import React, { useState, useEffect } from 'react'
import { Text, View, TouchableOpacity, ScrollView, Slider, Image, StatusBar, Platform } from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'
import styles from './Styles'
import { withNavigationItem, InjectedProps } from 'hybrid-navigation'

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 8 + 44,
      },
      {
        paddingTop: 8 + 20,
      },
    ),
  },
  android: {
    paddingTop: 12 + StatusBar.currentHeight!,
  },
})

export default withNavigationItem({
  topBarAlpha: 0.5,
  extendedLayoutIncludesTopBar: true,
  rightBarButtonItem: {
    icon: Image.resolveAssetSource(require('./images/settings.png')),
    title: 'SETTING',
    action: navigator => {
      navigator.push('TopBarMisc')
    },
  },
})(TopBarAlpha)

interface Props extends InjectedProps {
  color: string
  alpha: number
}

function TopBarAlpha({ garden, navigator, color, alpha }: Props) {
  const [topBarAlpha, setTopBarAlpha] = useState(alpha ? Number(alpha) : 0.5)
  let topBarColor = color || '#FFFFFF'

  useEffect(() => {
    garden.updateOptions({
      topBarAlpha: topBarAlpha,
      topBarColor: topBarColor,
    })
  }, [garden, topBarColor, topBarAlpha])

  function pushToTopBarAlpha() {
    navigator.push('TopBarAlpha')
  }

  function handleAlphaChange(value: number) {
    setTopBarAlpha(value)
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={[styles.container, paddingTop]}>
        <Text style={styles.welcome}>Try to slide</Text>

        <Slider
          style={{ marginLeft: 32, marginRight: 32, marginTop: 40 }}
          onValueChange={handleAlphaChange}
          step={0.01}
          value={topBarAlpha}
        />

        <Text style={styles.result}>alpha: {topBarAlpha}</Text>

        <TouchableOpacity onPress={pushToTopBarAlpha} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarAlpha</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}
