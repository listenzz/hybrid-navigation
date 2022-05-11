import React, { useEffect, ComponentType, useCallback } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Image } from 'react-native'
import {
  BarStyleLightContent,
  withNavigationItem,
  InjectedProps,
  NavigationItem,
  useVisibleEffect,
} from 'hybrid-navigation'
import { createStore } from 'redux'
import { connect, Provider } from 'react-redux'
import styles from './Styles'

interface Props extends InjectedProps {
  value: number
  onDecreaseClick: () => void
  onIncreaseClick: () => void
}

// React component
function ReduxCounter({ navigator, value, onDecreaseClick, onIncreaseClick }: Props) {
  useVisibleEffect(
    useCallback(() => {
      console.info(`Page ReduxCounter is visible`)
      return () => console.info(`Page ReduxCounter is invisible`)
    }, []),
  )

  useEffect(() => {
    navigator.setParams({ onDecreaseClick })
  })

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>{value}</Text>

        <TouchableOpacity onPress={onIncreaseClick} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Increase</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}

// Action

interface Action {
  type: string
}

const increaseAction: Action = { type: 'increase' }
const decreaseAction: Action = { type: 'decrease' }

interface State {
  count: number
}

// Reducer
function counter(state: State = { count: 0 }, action: Action) {
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
function mapStateToProps(state: { count: number }) {
  return {
    value: state.count,
  }
}

// Map Redux actions to component props
function mapDispatchToProps(dispatch: (action: Action) => void) {
  return {
    onIncreaseClick: () => dispatch(increaseAction),
    onDecreaseClick: () => dispatch(decreaseAction),
  }
}

const navigationItem: NavigationItem = {
  topBarStyle: BarStyleLightContent,
  titleTextColor: '#FFFF00',

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

export default connect(mapStateToProps, mapDispatchToProps)(withNavigationItem(navigationItem)(ReduxCounter))

export function withRedux(WrappedComponent: ComponentType<any>) {
  return class ReduxProvider extends React.Component {
    // 注意复制 navigationItem
    static navigationItem = (WrappedComponent as any).navigationItem

    static displayName = `withRedux(${WrappedComponent.displayName})`

    render() {
      return (
        // @ts-ignore
        <Provider store={store}>
          <WrappedComponent {...this.props} />
        </Provider>
      )
    }
  }
}
