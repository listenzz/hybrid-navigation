import React, { Component } from 'react';
import { Text, View, TouchableOpacity, ScrollView } from 'react-native';

import styles, { paddingTop } from './Styles';

export default class TopBarColor extends Component {
  static navigationItem = {
    extendedLayoutIncludesTopBar: true,
    topBarColor: '#FF0000',
  };

  constructor(props) {
    super(props);
    this.topBarColor = this.topBarColor.bind(this);
    this.red = this.red.bind(this);
    this.blue = this.blue.bind(this);
    this.green = this.green.bind(this);
  }

  red() {
    this.props.garden.setTopBarColor({ topBarColor: '#FF0000' });
  }

  green() {
    this.props.garden.setTopBarColor({ topBarColor: '#00FF00' });
  }

  blue() {
    this.props.garden.setTopBarColor({ topBarColor: '#0000FF' });
  }

  topBarColor() {
    this.props.navigator.push('TopBarColor');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.welcome}>Bright colors</Text>

          <TouchableOpacity onPress={this.red} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Red</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.blue} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Blue</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.green} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Green</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarColor} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBarColor</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
