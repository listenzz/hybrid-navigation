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
          <Text style={styles.welcome}>Keep an eye on the title, not 'The Origin Title'</Text>
        </View>
      </ScrollView>
    );
  }
}
