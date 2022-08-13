import React, { useEffect, useCallback } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Image } from 'react-native'
import {
  BarStyleLightContent,
  withNavigationItem,
  InjectedProps,
  useVisibleEffect,
} from 'hybrid-navigation'
import styles from './Styles'
import create from 'zustand'

interface CounterState {
  count: number
  increase: () => void
  decrease: () => void
}

const useStore = create<CounterState>(set => ({
  count: 0,
  increase: () => set(state => ({ count: state.count + 1 })),
  decrease: () => set(state => ({ count: state.count - 1 })),
}))

interface Props extends InjectedProps {}

// React component
function ZustandCounter({ navigator }: Props) {
  useVisibleEffect(
    useCallback(() => {
      console.info(`Page ZustandCounter is visible`)
      return () => console.info(`Page ZustandCounter is invisible`)
    }, []),
  )

  const { count, decrease, increase } = useStore(state => state)

  useEffect(() => {
    navigator.setParams({ onDecreaseClick: decrease })
  })

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>{count}</Text>

        <TouchableOpacity onPress={increase} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Increase</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}

export default withNavigationItem({
  topBarStyle: BarStyleLightContent,
  titleTextColor: '#FFFF00',

  titleItem: {
    title: 'Zustand Counter',
  },

  rightBarButtonItem: {
    title: 'MINUS',
    icon: Image.resolveAssetSource(require('./images/minus.png')),
    action: navigator => {
      navigator.state.params.onDecreaseClick()
    },
  },
})(ZustandCounter)
