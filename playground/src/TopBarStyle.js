import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView, Platform, Image } from 'react-native';

import styles, { paddingTop } from './Styles';

export default class TopBarStyle extends Component {
  static navigationItem = {
    extendedLayoutIncludesTopBar: true,
    topBarStyle: 'light-content',
    topBarTintColor: '#FFFFFF',
    titleTextColor: '#FFFF00',
    ...Platform.select({
      ios: {
        topBarColor: '#FF344C',
      },
      android: {
        topBarColor: '#F94D53',
      },
    }),

    titleItem: {
      title: 'TopBar Style',
    },

    rightBarButtonItem: {
      icon: Image.resolveAssetSource(require('./images/ic_settings.png')),
      title: 'SETTING',
      action: navigator => {
        console.info('setting button is clicked.');
      },
      tintColor: '#FFFFFF',
    },
  };

  constructor(props) {
    super(props);
    this.switchTopBarStyle = this.switchTopBarStyle.bind(this);
    this.topBarStyle = this.topBarStyle.bind(this);
    this.state = { topBarStyle: 'dark-content' };
  }

  switchTopBarStyle() {
    this.props.garden.setTopBarStyle({ topBarStyle: this.state.topBarStyle });
    if (this.state.topBarStyle === 'dark-content') {
      this.setState({ topBarStyle: 'light-content' });
    } else {
      this.setState({ topBarStyle: 'dark-content' });
    }
  }

  topBarStyle() {
    this.props.navigator.push('TopBarStyle');
  }
  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.text}>1. Status bar text can only be white on Android below 6.0</Text>

          <Text style={styles.text}>
            2. Status bar color may be adjusted if topBarStyle is dark-content on Android below 6.0
          </Text>

          <TouchableOpacity
            onPress={this.switchTopBarStyle}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>switch to {this.state.topBarStyle}</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarStyle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBarStyle</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
