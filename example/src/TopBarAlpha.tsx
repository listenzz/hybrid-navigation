import React, { useState, useEffect } from 'react'
import { Text, View, TouchableOpacity, ScrollView, Image } from 'react-native'
import Slider from '@react-native-community/slider'
import styles from './Styles'
import Navigation, { withNavigationItem, NavigationProps, statusBarHeight } from 'hybrid-navigation'

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

interface Props extends NavigationProps {
  color: string
  alpha: number
}

function TopBarAlpha({ sceneId, navigator, alpha }: Props) {
  const [topBarAlpha, setTopBarAlpha] = useState(alpha ? Number(alpha) : 0.5)

  useEffect(() => {
    Navigation.updateOptions(sceneId, {
      topBarAlpha,
    })
  }, [sceneId, topBarAlpha])

  function pushToTopBarAlpha() {
    navigator.push('TopBarAlpha')
  }

  function handleAlphaChange(value: number) {
    setTopBarAlpha(Number(value.toFixed(2)))
  }

  return (
    <ScrollView>
      <View style={[styles.container, { paddingTop: statusBarHeight() }]}>
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
