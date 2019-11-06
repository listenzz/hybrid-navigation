import React, { Component } from 'react'
import { TouchableOpacity, Text, View, ScrollView, StatusBar, Platform } from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'

import styles from './Styles'

function ifKitKat(obj1 = {}, obj2 = {}) {
  return Platform.Version > 18 ? obj1 : obj2
}

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 16 + 44,
      },
      {
        paddingTop: 16 + 20,
      },
    ),
  },
  android: {
    ...ifKitKat(
      {
        paddingTop: 16 + StatusBar.currentHeight,
      },
      {
        paddingTop: 16,
      },
    ),
  },
})

export default class topBarHidden extends Component {
  static navigationItem = {
    topBarHidden: true,
    titleItem: {
      title: 'You can not see me',
    },
  }

  constructor(props) {
    super(props)
    this.topBarHidden = this.topBarHidden.bind(this)
  }

  topBarHidden() {
    this.props.navigator.push('TopBarHidden')
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.welcome}>TopBar is hidden</Text>

          <TouchableOpacity onPress={this.topBarHidden} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBarHidden</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    )
  }
}
