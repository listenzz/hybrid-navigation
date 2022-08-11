import React, { useEffect, useCallback, useRef, ComponentType } from 'react'
import { StyleSheet, Animated, Easing, Dimensions, View, TouchableWithoutFeedback, SafeAreaView } from 'react-native'
import { useLayout, useBackHandler } from '@react-native-community/hooks'
import { InjectedProps } from 'hybrid-navigation'

export default function withBottomModal({
  cancelable = true,
  safeAreaColor = '#ffffff',
  navigationBarColor = '#ffffff',
} = {}) {
  return function (WrappedComponent: ComponentType<any>) {
    function BottomModal(props: InjectedProps, ref: React.Ref<ComponentType<any>>) {
      const animatedHeight = useRef(new Animated.Value(Dimensions.get('screen').height))
      const { onLayout, height } = useLayout()

      const realHideModal = useRef(props.navigator.hideModal)

      const hideModal = useCallback(() => {
        return new Promise<boolean>(resolve => {
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
            useNativeDriver: true,
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
          ]}>
          <TouchableWithoutFeedback onPress={handleHardwareBackPress} style={styles.flex1}>
            <View style={styles.flex1} />
          </TouchableWithoutFeedback>

          <View onLayout={onLayout}>
            <WrappedComponent {...props} ref={ref} />
            <SafeAreaView style={{ backgroundColor: safeAreaColor }} />
          </View>
        </Animated.View>
      )
    }

    const FC = React.forwardRef(BottomModal)
    const name = WrappedComponent.displayName || WrappedComponent.name
    FC.displayName = `withBottomModal(${name})`

    const navigationItem = (WrappedComponent as any).navigationItem || {}
    if (!navigationItem.navigationBarColorAndroid) {
      navigationItem.navigationBarColorAndroid = navigationBarColor
    }
    ;(FC as any).navigationItem = navigationItem

    return FC
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
