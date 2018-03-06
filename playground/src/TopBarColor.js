/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { Text, View, TouchableOpacity, ScrollView } from 'react-native';

import styles from './Styles';

export default class TopBarColor extends Component {
  static navigationItem = {
    topBarColor: '#FF0000',
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
    this.topBarHidden = this.topBarHidden.bind(this);
    this.topBarColor = this.topBarColor.bind(this);
    this.topBarAlpha = this.topBarAlpha.bind(this);
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

  topBarHidden() {
    this.props.navigator.push('TopBarHidden');
  }

  topBarColor() {
    this.props.navigator.push('TopBarColor');
  }

  topBarAlpha() {
    this.props.navigator.push('TopBarAlpha');
  }

  topBarTitleView() {
    this.props.navigator.push('TopBarTitleView');
  }

  render() {
    return (
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.container}>
          <Text style={styles.welcome}>鲜艳的颜色</Text>

          <TouchableOpacity onPress={this.red} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Red</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.blue} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Blue</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.green} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Green</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarHidden} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar hidden</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarColor} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar color</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarAlpha} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar alpha</Text>
          </TouchableOpacity>

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
