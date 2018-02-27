/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { Text, View } from 'react-native';

import styles from './Styles';

export default class PassOptions extends Component {
  static navigationItem = {
    titleItem: {
      title: 'The Origin Title',
    },
  };

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>留意标题，并不是 'The Origin Title'</Text>
      </View>
    );
  }
}
