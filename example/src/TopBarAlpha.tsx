import React, { useState, useEffect } from 'react'
import { Text, View, TouchableOpacity, ScrollView, Slider, Image } from 'react-native'
import styles from './Styles'
import { withNavigationItem, InjectedProps, Garden } from 'hybrid-navigation'

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

function TopBarAlpha({ garden, navigator, alpha }: Props) {
  const [topBarAlpha, setTopBarAlpha] = useState(alpha ? Number(alpha) : 0.5)

  useEffect(() => {
    garden.updateOptions({
      topBarAlpha,
    })
  }, [garden, topBarAlpha])

  function pushToTopBarAlpha() {
    navigator.push('TopBarAlpha')
  }

  function handleAlphaChange(value: number) {
    setTopBarAlpha(Number(value.toFixed(2)))
  }

  return (
    <ScrollView>
      <View style={[styles.container, { paddingTop: Garden.statusBarHeight() }]}>
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
