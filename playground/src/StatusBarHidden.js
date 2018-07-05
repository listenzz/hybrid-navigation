import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

import styles from './Styles';

export default class StatusBarHidden extends Component {
  static navigationItem = {
    statusBarColor: '#00FF00',
    statusBarHidden: true,
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
