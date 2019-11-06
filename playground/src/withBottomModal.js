import React, { Component } from 'react'
import { StyleSheet, Animated, Easing, Dimensions, View, TouchableWithoutFeedback, SafeAreaView } from 'react-native'
import { isIphoneX } from 'react-native-iphone-x-helper'
import { useBackEffect } from 'react-native-navigation-hybrid'

function BackHandler({ sceneId, handleHardwareBackPress }) {
  useBackEffect(sceneId, handleHardwareBackPress)
  return null
}

export default function withBottomModal(cancelable = true, safeAreaColor = '#00000000') {
  return function(WrappedComponent) {
    class BottomModal extends Component {
      height = 0
      constructor(props) {
        super(props)
        this.state = {
          anim: new Animated.Value(Dimensions.get('screen').height),
        }
        this.handleLayout = this.handleLayout.bind(this)
        this.hideModal = this.hideModal.bind(this)
        this.handleHardwareBackPress = this.handleHardwareBackPress.bind(this)
        this.realHideModal = this.props.navigator.hideModal
        this.props.navigator.hideModal = this.hideModal
      }

      handleLayout(e) {
        if (this.height !== 0) {
          return
        }
        const height = e.nativeEvent.layout.height
        this.height = height
        const { anim } = this.state
        anim.setValue(height)
        Animated.timing(anim, {
          toValue: 0,
          duration: 250,
          easing: Easing.linear,
        }).start()
      }

      handleHardwareBackPress() {
        cancelable && this.hideModal()
      }

      hideModal() {
        Animated.timing(this.state.anim, {
          toValue: this.height,
          duration: 200,
          easing: Easing.linear,
        }).start(() => this.realHideModal())
      }

      render() {
        const { anim } = this.state
        const { forwardedRef, ...props } = this.props
        return (
          <Animated.View
            style={[
              styles.container,
              {
                transform: [{ translateY: anim }],
              },
            ]}
            useNativeDriver>
            <BackHandler sceneId={this.props.sceneId} handleHardwareBackPress={this.handleHardwareBackPress} />
            <TouchableWithoutFeedback onPress={this.handleHardwareBackPress} style={styles.flex1}>
              <View style={styles.flex1} />
            </TouchableWithoutFeedback>

            <View onLayout={this.handleLayout}>
              <WrappedComponent {...props} ref={forwardedRef} />
              {isIphoneX() && <SafeAreaView style={{ backgroundColor: safeAreaColor }} />}
            </View>
          </Animated.View>
        )
      }
    }

    const C = React.forwardRef((props, ref) => {
      return <BottomModal {...props} forwardedRef={ref} />
    })
    const name = WrappedComponent.displayName || WrappedComponent.name
    C.navigationItem = WrappedComponent.navigationItem
    C.displayName = `withBottomModal(${name})`
    return C
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
