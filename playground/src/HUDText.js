import React, { Component } from 'react';

import { Text, View, TouchableOpacity } from 'react-native';
import styles from './Styles';
import HUD, { LoadingHUD } from 'react-native-hud-hybrid';

export default class HUDTest extends Component {
  constructor(props) {
    super(props);
    this.loading = this.loading.bind(this);
  }

  componentDidMount() {
    HUD.config({
      // backgroundColor: '#BB000000',
      // tintColor: '#FFFFFF',
      // cornerRadius: 5, // only for android
      // duration: 2000,
      // graceTime: 300,
      // minShowTime: 800,
      // dimAmount: 0.0, // only for andriod
      loadingText: 'Loading...',
    });
    this.hud = new LoadingHUD();
  }

  componentWillUnmount() {
    this.hud.hideAll();
  }

  loading() {
    this.hud.show();
    setTimeout(() => {
      new HUD().done('Work is Done!').hideDelayDefault();
      this.hud.hide();
    }, 2000);
  }

  text() {
    new HUD().text('Hello World!!').hideDelayDefault();
  }

  info() {
    new HUD().info('A message to you.').hideDelayDefault();
  }

  done() {
    new HUD().done('Work is Done!').hideDelayDefault();
  }

  error() {
    new HUD().error('Somthing Wrong!').hideDelayDefault();
  }

  render() {
    return (
      <View style={styles.container}>
        <TouchableOpacity onPress={this.loading} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> loading </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.text} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> text </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.info} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> info </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.done} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> done </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.error} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> error </Text>
        </TouchableOpacity>
      </View>
    );
  }
}
