/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

import styles from './Styles';

export default class StatusBarColor extends Component {
  static navigationItem = {
    statusBarColor: '#00FFFF',

    titleItem: {
      title: '状态栏颜色',
    },
  };

  constructor(props) {
    super(props);
    this.red = this.red.bind(this);
    this.blue = this.blue.bind(this);
    this.green = this.green.bind(this);
    this.topBarStyle = this.topBarStyle.bind(this);
  }

  red() {
    this.props.garden.setStatusBarColor({ statusBarColor: '#FF0000' });
  }

  green() {
    this.props.garden.setStatusBarColor({ statusBarColor: '#00FF00' });
  }

  blue() {
    this.props.garden.setStatusBarColor({ statusBarColor: '#0000FF' });
  }

  topBarStyle() {
    this.props.navigator.push('TopBarStyle');
  }

  render() {
    return (
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.container}>
          <Text style={styles.welcome}>仅对 Android 生效</Text>
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

        <TouchableOpacity onPress={this.topBarStyle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarStyle</Text>
        </TouchableOpacity>
      </ScrollView>
    );
  }
}
