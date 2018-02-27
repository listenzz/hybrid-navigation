/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { TouchableOpacity, Text, View } from 'react-native';

import { createStore } from 'redux';
import { connect } from 'react-redux';

import styles from './Styles';
import fontUri from './FontUtil';

const ON_MINUS_CLICK = 'minus';

// React component
class Counter extends Component {
  static navigationItem = {
    titleItem: {
      title: 'Redux Counter',
    },

    rightBarButtonItem: {
      icon: { uri: fontUri('FontAwesome', 'minus', 24) },
      title: 'MINUS',
      action: ON_MINUS_CLICK,
    },
  };

  componentWillMount() {
    const { navigator, onDecreaseClick } = this.props;
    navigator.onBarButtonItemClick = onDecreaseClick;
  }

  render() {
    const { value, onIncreaseClick } = this.props;
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>{value}</Text>

        <TouchableOpacity onPress={onIncreaseClick} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Increase</Text>
        </TouchableOpacity>
      </View>
    );
  }
}

// Action
const increaseAction = { type: 'increase' };
const decreaseAction = { type: 'decrease' };

// Reducer
function counter(state = { count: 0 }, action) {
  const count = state.count;
  switch (action.type) {
    case 'increase':
      return { count: count + 1 };
    case 'decrease':
      return { count: count - 1 };
    default:
      return state;
  }
}

// Store
const store = createStore(counter);

// Map Redux state to component props
function mapStateToProps(state) {
  return {
    value: state.count,
  };
}

// Map Redux actions to component props
function mapDispatchToProps(dispatch) {
  return {
    onIncreaseClick: () => dispatch(increaseAction),
    onDecreaseClick: () => dispatch(decreaseAction),
  };
}

// Connected Component
export default connect(mapStateToProps, mapDispatchToProps)(Counter);

export { store };
