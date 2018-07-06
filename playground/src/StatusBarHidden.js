import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView, StatusBar, Platform } from 'react-native';
import { ifIphoneX } from 'react-native-iphone-x-helper';

import styles from './Styles';

function ifKitKat(obj1 = {}, obj2 = {}) {
  return Platform.Version > 18 ? obj1 : obj2;
}

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 16 + 44,
      },
      {
        paddingTop: 16 + 20,
      }
    ),
  },
  android: {
    ...ifKitKat(
      {
        paddingTop: 16 + StatusBar.currentHeight,
      },
      {
        paddingTop: 16,
      }
    ),
  },
});

export default class StatusBarHidden extends Component {
  static navigationItem = {
    statusBarColor: '#00FF00',
    statusBarHidden: true,
    topBarHidden: true,
    titleItem: {
      title: '隐藏状态栏',
    },
  };

  constructor(props) {
    super(props);
    this.showStatusBar = this.showStatusBar.bind(this);
    this.hideStatusBar = this.hideStatusBar.bind(this);
    this.topBarStyle = this.topBarStyle.bind(this);
  }

  topBarStyle() {
    this.props.navigator.push('TopBarStyle');
  }

  showStatusBar() {
    this.props.garden.setStatusBarHidden(false);
  }

  hideStatusBar() {
    this.props.garden.setStatusBarHidden();
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <Text style={[styles.welcome, paddingTop]}> StatusBar Hidden</Text>
        <TouchableOpacity onPress={this.showStatusBar} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>show status bar</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.hideStatusBar} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>hide status bar</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.topBarStyle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBarStyle</Text>
        </TouchableOpacity>
      </ScrollView>
    );
  }
}
