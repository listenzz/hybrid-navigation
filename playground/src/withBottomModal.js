import React, { useEffect, useState, useCallback, useRef } from 'react'
import {
  StyleSheet,
  Animated,
  Easing,
  Dimensions,
  View,
  TouchableWithoutFeedback,
  SafeAreaView,
} from 'react-native'
import { isIphoneX } from 'react-native-iphone-x-helper'
import { useLayout, useBackHandler } from '@react-native-community/hooks'

export default function withBottomModal({
  cancelable = true,
  safeAreaColor = '#ffffff',
  navigationBarColor = '#ffffff',
} = {}) {
  return function(WrappedComponent) {
    function BottomModal(props, ref) {
      const animatedHeight = useRef(new Animated.Value(Dimensions.get('screen').height))

      const { onLayout, height } = useLayout()

      const realHideModal = useRef(props.navigator.hideModal)

      const hideModal = useCallback(() => {
        return new Promise(resolve => {
          Animated.timing(animatedHeight.current, {
            toValue: height,
            duration: 200,
            easing: Easing.linear,
            useNativeDriver: true,
          }).start(() => {
            resolve(realHideModal.current())
          })
        })
      }, [height])

      props.navigator.hideModal = hideModal

      useEffect(() => {
        if (height !== 0) {
          animatedHeight.current.setValue(height)
          Animated.timing(animatedHeight.current, {
            toValue: 0,
            duration: 250,
            easing: Easing.linear,
          }).start()
        }
      }, [height])

      const handleHardwareBackPress = useCallback(() => {
        cancelable && hideModal()
        return true
      }, [hideModal])

      useBackHandler(handleHardwareBackPress)

      return (
        <Animated.View
          style={[
            styles.container,
            {
              transform: [{ translateY: animatedHeight.current }],
            },
          ]}
          useNativeDriver>
          <TouchableWithoutFeedback onPress={handleHardwareBackPress} style={styles.flex1}>
            <View style={styles.flex1} />
          </TouchableWithoutFeedback>

          <View onLayout={height === 0 ? onLayout : undefined}>
            <WrappedComponent {...props} ref={ref} />
            {isIphoneX() && <SafeAreaView style={{ backgroundColor: safeAreaColor }} />}
          </View>
        </Animated.View>
      )
    }

    const FREC = React.forwardRef(BottomModal)
    const name = WrappedComponent.displayName || WrappedComponent.name
    FREC.displayName = `withBottomModal(${name})`

    const navigationItem = WrappedComponent.navigationItem || {}
    if (!navigationItem.navigationBarColorAndroid) {
      navigationItem.navigationBarColorAndroid = navigationBarColor
    }
    FREC.navigationItem = navigationItem

    return FREC
  }
}

const styles = StyleSheet.create({
  container: {
    opacity: 1,
    flex: 1,
    justifyContent: 'flex-end',
  },
  flex1: {
    flex: 1,
  },
})
