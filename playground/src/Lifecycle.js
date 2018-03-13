/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView, Alert } from 'react-native';

import styles from './Styles';

export default class Lifecycle extends Component {
  static navigationItem = {
    titleItem: {
      title: 'Lifecycle Alert',
    },
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
  }

  componentDidAppear() {
    Alert.alert(
      'Lifecycle Alert!',
      'componentDidAppear.',
      [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
      { cancelable: false }
    );
  }

  componentDidDisappear() {
    Alert.alert(
      'Lifecycle Alert!',
      'componentDidDisappear.',
      [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
      { cancelable: false }
    );
  }

  topBarTitleView() {
    this.props.navigation.push('TopBarTitleView');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>额外的生命周期演示</Text>

          <TouchableOpacity
            onPress={this.topBarTitleView}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>TopBar title view</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
