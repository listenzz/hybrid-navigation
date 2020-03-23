import React, { useEffect } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Platform, Image } from 'react-native'
import {
  BarStyleLightContent,
  withNavigationItem,
  useVisibility,
} from 'react-native-navigation-hybrid'
import { createStore } from 'redux'
import { connect } from 'react-redux'
import styles, { paddingTop } from './Styles'

// React component
function ReduxCounter({ sceneId, navigator, value, onDecreaseClick, onIncreaseClick }) {
  useVisibility(sceneId, visible => {
    if (visible) {
      console.info(`Page ReduxCounter is visible`)
    } else {
      console.info(`Page ReduxCounter is gone`)
    }
  })

  useEffect(() => {
    navigator.setParams({ onDecreaseClick })
  })

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={[styles.container, paddingTop]}>
        <Text style={styles.welcome}>{value}</Text>

        <TouchableOpacity onPress={onIncreaseClick} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Increase</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}

// Action
const increaseAction = { type: 'increase' }
const decreaseAction = { type: 'decrease' }

// Reducer
function counter(state = { count: 0 }, action) {
  const count = state.count
  switch (action.type) {
    case 'increase':
      return { count: count + 1 }
    case 'decrease':
      return { count: count - 1 }
    default:
      return state
  }
}

// Store
const store = createStore(counter)

// Map Redux state to component props
function mapStateToProps(state) {
  return {
    value: state.count,
  }
}

// Map Redux actions to component props
function mapDispatchToProps(dispatch) {
  return {
    onIncreaseClick: () => dispatch(increaseAction),
    onDecreaseClick: () => dispatch(decreaseAction),
  }
}

const navigationItem = {
  extendedLayoutIncludesTopBar: true,
  topBarStyle: BarStyleLightContent,
  topBarTintColor: '#FFFFFF',
  titleTextColor: '#FFFF00',
  ...Platform.select({
    ios: {
      topBarColor: '#FF344C',
    },
    android: {
      topBarColor: '#F94D53',
    },
  }),
  titleItem: {
    title: 'Redux Counter',
  },

  rightBarButtonItem: {
    title: 'MINUS',
    icon: Image.resolveAssetSource(require('./images/minus.png')),
    action: navigator => {
      navigator.state.params.onDecreaseClick()
    },
  },
}

// Connected Component
// export default withNavigationItem(navigationItem)(
//   connect(mapStateToProps, mapDispatchToProps)(ReduxCounter),
// )

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(withNavigationItem(navigationItem)(ReduxCounter))

export { store }
