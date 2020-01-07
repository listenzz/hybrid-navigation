import React, { Component } from 'react'
import { TouchableOpacity, Text, View, StatusBar, Platform } from 'react-native'
import { ifIphoneX } from 'react-native-iphone-x-helper'
import { Garden, Navigator } from 'react-native-navigation-hybrid'

import styles from './Styles'

function ifKitKat(obj1 = {}, obj2 = {}) {
  return Platform.Version > 18 ? obj1 : obj2
}

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 16 + 88,
      },
      {
        paddingTop: 16 + 64,
      },
    ),
  },
  android: {
    ...ifKitKat(
      {
        paddingTop: 16 + StatusBar.currentHeight + Garden.toolbarHeight,
      },
      {
        paddingTop: 16 + Garden.toolbarHeight,
      },
    ),
  },
})

export default class Menu extends Component {
  constructor(props) {
    super(props)
    this.push = this.push.bind(this)
    this.pushToRedux = this.pushToRedux.bind(this)
    this.pushToToast = this.pushToToast.bind(this)
  }

  componentDidAppear() {
    console.info('menu componentDidAppear')
  }

  componentDidDisappear() {
    console.info('menu componentDidDisappear')
  }

  componentDidMount() {
    console.info('menu componentDidMount')
  }

  componentWillUnmount() {
    console.info('menu componentWillUnmount')
  }

  push() {
    this.props.navigator.closeMenu()
    this.props.navigator.push('OneNative')
  }

  pushToRedux() {
    this.props.navigator.closeMenu()
    this.props.navigator.push('ReduxCounter')
  }

  pushToToast() {
    this.props.navigator.closeMenu()
    this.props.navigator.push('Toast')
  }

  render() {
    return (
      <View style={[styles.container, paddingTop]}>
        <Text style={styles.welcome}>This's a React Native Menu.</Text>

        <TouchableOpacity onPress={this.push} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>push to native</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.pushToRedux} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Redux Counter</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.pushToToast} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Toast</Text>
        </TouchableOpacity>
      </View>
    )
  }
}
