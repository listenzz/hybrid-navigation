import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView, Platform, Image } from 'react-native';

import styles from './Styles';

export default class Transparent extends Component {
  static navigationItem = {
    screenColor: '#00000000',
    passThroughTouches: true,
  };

  constructor(props) {
    super(props);
  }

  log() {
    console.info('Transparent !!');
  }

  render() {
    return (
      <View style={{ flex: 1 }}>
        <View style={{ flex: 1 }}>
          <View style={styles.transparent}>
            <TouchableOpacity onPress={this.log} activeOpacity={0.2} style={styles.button}>
              <Text style={styles.buttonText}>点我</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    );
  }
}
