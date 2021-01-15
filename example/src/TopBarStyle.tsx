import React, { useState, useEffect } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Image } from 'react-native'
import { BarStyleLightContent, BarStyleDarkContent, InjectedProps, Style } from 'hybrid-navigation'
import styles from './Styles'
import { withNavigationItem } from 'hybrid-navigation'

export default withNavigationItem({
  topBarStyle: BarStyleLightContent,

  titleItem: {
    title: 'TopBar Style',
  },

  rightBarButtonItem: {
    icon: Image.resolveAssetSource(require('./images/settings.png')),
    action: (navigator) => {
      navigator.push('TopBarMisc')
    },
  },
})(TopBarStyle)

function TopBarStyle({ navigator, garden }: InjectedProps) {
  const [style, setStyle] = useState<Style>()

  useEffect(() => {
    if (style) {
      garden.updateOptions(style)
    }
  }, [style, garden])

  function switchTopBarStyle() {
    if (style && style.topBarStyle === BarStyleDarkContent) {
      setStyle({
        topBarStyle: BarStyleLightContent,
      })
    } else {
      setStyle({
        topBarStyle: BarStyleDarkContent,
      })
    }
  }

  function topBarStyle() {
    navigator.push('TopBarStyle')
  }

  async function showModal() {
    await navigator.showModal('ReactModal')
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.text}>1. Status bar text can only be white on Android below 6.0</Text>

        <Text style={styles.text}>
          2. Status bar color may be adjusted if topBarStyle is dark-content on Android below 6.0
        </Text>

        <TouchableOpacity onPress={switchTopBarStyle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>
            switch to{' '}
            {style && style.topBarStyle === BarStyleDarkContent
              ? 'Light Content Style'
              : 'Dark Content Style'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={topBarStyle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarStyle</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>show react modal</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}
