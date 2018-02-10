import React, { Component } from 'react';
import {
	TouchableOpacity,
	Text,
  View,
  Image,
} from 'react-native';

import { createStore } from 'redux'
import { Provider, connect } from 'react-redux'

import styles from './Styles'

// React component
class Counter extends Component {

	static navigationItem = {

		titleItem: {
			title: 'Redux Counter',
		},

	}

	render() {
		const { value, onIncreaseClick } = this.props;
		return (
			<View style={styles.container}>
				<Text style={styles.welcome}>
					{value}
				</Text>

				<TouchableOpacity onPress={onIncreaseClick} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						Increase
					</Text>
				</TouchableOpacity>
			</ View>
		);
	}

}

// Action
const increaseAction = { type: 'increase' }

// Reducer
function counter(state = { count: 0 }, action) {
  const count = state.count
  switch (action.type) {
    case 'increase':
      return { count: count + 1 }
    default:
      return state
  }
}

// Store
const store = createStore(counter)

// Map Redux state to component props
function mapStateToProps(state) {
  return {
    value: state.count
  }
}

// Map Redux actions to component props
function mapDispatchToProps(dispatch) {
  return {
    onIncreaseClick: () => dispatch(increaseAction)
  }
}

// Connected Component
export default App = connect(
  mapStateToProps,
  mapDispatchToProps
)(Counter)

export {
	store,
}
