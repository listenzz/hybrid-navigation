/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { Text, View } from 'react-native';

import styles from './Styles';

export default class HideTopBarShadow extends Component {
  static navigationItem = {
    // 注意这行代码，隐藏了 top bar 的阴影
    hideShadow: true,

    titleItem: {
      title: 'Hide Shadow',
    },
  };

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>现在，topBar 的阴影没有了。</Text>
      </View>
    );
  }
}
