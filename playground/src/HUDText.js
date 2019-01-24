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
    this.loadingHud = new LoadingHUD();
  }

  componentWillUnmount() {
    this.loadingHud.hideAll();
  }

  loading() {
    // this.loadingHud.show();
    // setTimeout(() => {
    //   this.loadingHud.hide();
    //   new HUD().done('Work is Done!').hideDelayDefault();
    // }, 2000);

    const hud = HUD.spinner();
    setTimeout(() => {
      hud.text('Ho Ho Ho');
      hud.hideDelayDefault();
    }, 2000);
  }

  text() {
    HUD.text('Hello World!!');
  }

  info() {
    HUD.info('A message to you.');
  }

  done() {
    HUD.done('Work is Done!');
  }

  error() {
    HUD.error('Somthing Wrong!');
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
