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

export default class topBarHidden extends Component {
  static navigationItem = {
    topBarHidden: true,
    titleItem: {
      title: '看不见我',
    },
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
    this.topBarHidden = this.topBarHidden.bind(this);
    this.topBarColor = this.topBarColor.bind(this);
    this.topBarAlpha = this.topBarAlpha.bind(this);
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
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.welcome}>TopBar 不见了</Text>

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
