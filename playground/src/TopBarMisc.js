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
    titleItem: {
      title: 'TopBar Options',
    },
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
    this.topBarHidden = this.topBarHidden.bind(this);
    this.topBarColor = this.topBarColor.bind(this);
    this.topBarAlpha = this.topBarAlpha.bind(this);
    this.topBarBackButtonHidden = this.topBarBackButtonHidden.bind(this);
    this.topBarShadowHidden = this.topBarShadowHidden.bind(this);
    this.statusBarColor = this.statusBarColor.bind(this);
    this.topBarStyle = this.topBarStyle.bind(this);
  }

  topBarBackButtonHidden() {
    this.props.navigator.push('TopBarBackButtonHidden');
  }

  topBarShadowHidden() {
    this.props.navigator.push('TopBarShadowHidden');
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

  statusBarColor() {
    this.props.navigator.push('StatusBarColor');
  }

  topBarStyle() {
    this.props.navigator.push('TopBarStyle');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={true}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>About TopBar</Text>
          <TouchableOpacity
            onPress={this.topBarShadowHidden}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>TopBar shadow hidden</Text>
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

          <TouchableOpacity
            onPress={this.topBarBackButtonHidden}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>hide back button</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.statusBarColor} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>StatusBar color</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarStyle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar style</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
