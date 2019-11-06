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

export default class StatusBarHidden extends Component {
  static navigationItem = {
    statusBarColorAndroid: '#00FF00',
    statusBarHidden: true,
    topBarHidden: true,
    titleItem: {
      title: 'StatusBar Hidden',
    },
  }

  constructor(props) {
    super(props)
    this.showStatusBar = this.showStatusBar.bind(this)
    this.hideStatusBar = this.hideStatusBar.bind(this)
    this.statusBarHidden = this.statusBarHidden.bind(this)
  }

  statusBarHidden() {
    this.props.navigator.push('StatusBarHidden')
  }

  showStatusBar() {
    this.props.garden.updateOptions({ statusBarHidden: false })
  }

  hideStatusBar() {
    this.props.garden.updateOptions({ statusBarHidden: true })
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
        <Text style={[styles.welcome, paddingTop]}> StatusBar Hidden</Text>
        <TouchableOpacity onPress={this.showStatusBar} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>show status bar</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.hideStatusBar} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>hide status bar</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.statusBarHidden} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>StatusBarHidden</Text>
        </TouchableOpacity>
      </ScrollView>
    )
  }
}
