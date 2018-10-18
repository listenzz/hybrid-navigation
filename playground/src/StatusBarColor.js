import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

import styles from './Styles';

export default class StatusBarColor extends Component {
  static navigationItem = {
    statusBarColorAndroid: '#0000FF',
    titleItem: {
      title: 'StatusBar Color',
    },
  };

  constructor(props) {
    super(props);
    this.red = this.red.bind(this);
    this.blue = this.blue.bind(this);
    this.green = this.green.bind(this);
    this.statusBarColor = this.statusBarColor.bind(this);
  }

  red() {
    this.props.garden.setStatusBarColorAndroid({ statusBarColor: '#FF0000' });
  }

  green() {
    this.props.garden.setStatusBarColorAndroid({ statusBarColor: '#00FF00' });
  }

  blue() {
    this.props.garden.setStatusBarColorAndroid({ statusBarColor: '#0000FF' });
  }

  statusBarColor() {
    this.props.navigator.push('StatusBarColor');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>For Android only</Text>
        </View>

        <TouchableOpacity onPress={this.red} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Red</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.blue} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Blue</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.green} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Green</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.statusBarColor} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>StatucsBarColor</Text>
        </TouchableOpacity>
      </ScrollView>
    );
  }
}
