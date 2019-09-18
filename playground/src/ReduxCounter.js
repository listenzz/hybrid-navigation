import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView, Platform, Image } from 'react-native';
import { BarStyleLightContent } from 'react-native-navigation-hybrid';
import { createStore } from 'redux';
import { connect } from 'react-redux';
import styles, { paddingTop } from './Styles';

// React component
class ReduxCounter extends Component {
  static navigationItem = {
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
        navigator.state.params.onDecreaseClick();
      },
    },
  };

  constructor(props) {
    super(props);
    const { navigator, onDecreaseClick } = props;
    navigator.setParams({ onDecreaseClick });
  }

  componentDidAppear() {
    console.info('ReduxCounter componentDidAppear');
  }

  componentDidDisappear() {
    console.info('ReduxCounter componentDidDisappear');
  }

  render() {
    const { value, onIncreaseClick } = this.props;
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.welcome}>{value}</Text>

          <TouchableOpacity onPress={onIncreaseClick} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Increase</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
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
export default connect(
  mapStateToProps,
  mapDispatchToProps,
  undefined,
  { forwardRef: true } // 注意这行代码，开启引用转发功能
)(ReduxCounter);

export { store };
