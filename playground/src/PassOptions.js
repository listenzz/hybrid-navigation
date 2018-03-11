/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { Text, View, ScrollView } from 'react-native';

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
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>留意标题，并不是 'The Origin Title'</Text>
        </View>
      </ScrollView>
    );
  }
}
