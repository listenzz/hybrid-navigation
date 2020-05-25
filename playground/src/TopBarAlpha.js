import React, { useState, useEffect } from 'react'
import {
  Text,
  View,
  TouchableOpacity,
  ScrollView,
  Slider,
  Image,
  StatusBar,
  Platform,
} from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'
import styles from './Styles'
import { withNavigationItem } from 'react-native-navigation-hybrid'

function ifKitKat(obj1 = {}, obj2 = {}) {
  return Platform.Version > 18 ? obj1 : obj2
}

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
    ...ifKitKat(
      {
        paddingTop: 12 + StatusBar.currentHeight,
      },
      {
        paddingTop: 12,
      },
    ),
  },
})

export default withNavigationItem({
  topBarAlpha: 0.5,
  extendedLayoutIncludesTopBar: true,
  rightBarButtonItem: {
    icon: Image.resolveAssetSource(require('./images/settings.png')),
    title: 'SETTING',
    action: (navigator) => {
      navigator.push('TopBarMisc')
    },
  },
})(TopBarAlpha)

function TopBarAlpha({ garden, navigator, color, alpha }) {
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

  function handleAlphaChange(value) {
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
