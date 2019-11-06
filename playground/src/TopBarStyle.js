import React, { Component } from 'react'
import { TouchableOpacity, Text, View, ScrollView, Platform, Image } from 'react-native'
import { BarStyleLightContent, BarStyleDarkContent } from 'react-native-navigation-hybrid'
import styles, { paddingTop } from './Styles'

export default class TopBarStyle extends Component {
  static navigationItem = {
    extendedLayoutIncludesTopBar: true,
    topBarStyle: BarStyleLightContent,
    topBarTintColor: '#FFFFFF',
    titleTextColor: '#FFFFFF',
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
      icon: Image.resolveAssetSource(require('./images/settings.png')),
      action: navigator => {
        navigator.push('TopBarMisc')
      },
    },
  }

  constructor(props) {
    super(props)
    this.switchTopBarStyle = this.switchTopBarStyle.bind(this)
    this.topBarStyle = this.topBarStyle.bind(this)
    this.state = {
      topBarStyle: BarStyleDarkContent,
      topBarTintColor: '#000000',
    }
    this.showModal = this.showModal.bind(this)
  }

  switchTopBarStyle() {
    this.props.garden.updateOptions({
      topBarStyle: this.state.topBarStyle,
      topBarTintColor: this.state.topBarTintColor,
      titleTextColor: this.state.topBarTintColor,
    })
    if (this.state.topBarStyle === BarStyleDarkContent) {
      this.setState({ topBarStyle: BarStyleLightContent, topBarTintColor: '#FFFFFF' })
    } else {
      this.setState({ topBarStyle: BarStyleDarkContent, topBarTintColor: '#000000' })
    }
  }

  topBarStyle() {
    this.props.navigator.push('TopBarStyle')
  }

  async showModal() {
    await this.props.navigator.showModal('ReactModal', 1)
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.text}>1. Status bar text can only be white on Android below 6.0</Text>

          <Text style={styles.text}>
            2. Status bar color may be adjusted if topBarStyle is dark-content on Android below 6.0
          </Text>

          <TouchableOpacity onPress={this.switchTopBarStyle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>switch to {this.state.topBarStyle}</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarStyle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBarStyle</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.showModal} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>show react modal</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    )
  }
}
