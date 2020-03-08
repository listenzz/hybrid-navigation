import React, { Component } from 'react'
import { TouchableOpacity, Text, View, Image, ScrollView, PixelRatio } from 'react-native'
import { Navigator } from 'react-native-navigation-hybrid'

import styles from './Styles'
import getLayout from './layout'

export default class Options extends Component {
  static navigationItem = {
    titleItem: {
      title: 'Options',
    },

    leftBarButtonItem: {
      icon: Image.resolveAssetSource(require('./images/menu.png')),
      title: 'Menu',
      action: navigator => {
        navigator.toggleMenu()
      },
    },

    rightBarButtonItem: {
      icon: Image.resolveAssetSource(require('./images/nav.png')),
      title: 'SETTING',
      action: navigator => {
        navigator.push('TopBarMisc')
      },
      enabled: false,
    },

    tabItem: {
      title: 'Options',
      icon: Image.resolveAssetSource(require('./images/flower_1.png')),
      hideTabBarWhenPush: true,
    },
  }

  constructor(props) {
    super(props)
    this.changeLeftButton = this.changeLeftButton.bind(this)
    this.changeRightButton = this.changeRightButton.bind(this)
    this.changeTitle = this.changeTitle.bind(this)
    this.topBarMisc = this.topBarMisc.bind(this)
    this.passOptions = this.passOptions.bind(this)
    this.switchTab = this.switchTab.bind(this)
    this.toggleTabBadge = this.toggleTabBadge.bind(this)
    this.lifecycle = this.lifecycle.bind(this)
    this.replaceTabIcon = this.replaceTabIcon.bind(this)
    this.replaceTabItemColor = this.replaceTabItemColor.bind(this)
    this.setTabBarColor = this.setTabBarColor.bind(this)
    this.changeTabBar = this.changeTabBar.bind(this)
    this.state = {
      leftButtonShowText: true,
      rightButtonEnabled: false,
      title: '配置',
      badge: null,
    }
  }

  componentDidMount() {
    console.info('options componentDidMount')
  }

  componentDidAppear() {
    console.info('options componentDidAppear')
    this.props.navigator.isStackRoot().then(isRoot => {
      this.props.garden.setMenuInteractive(isRoot)
    })
  }

  componentDidDisappear() {
    console.info('options componentDidDisappear')
    this.props.garden.setMenuInteractive(false)
  }

  changeLeftButton() {
    if (this.state.leftButtonShowText) {
      this.props.garden.setLeftBarButtonItem({ icon: null })
    } else {
      this.props.garden.setLeftBarButtonItem({
        icon: Image.resolveAssetSource(require('./images/menu.png')),
      })
    }
    this.setState({ leftButtonShowText: !this.state.leftButtonShowText })
  }

  changeRightButton() {
    this.props.garden.setRightBarButtonItem({
      enabled: !this.state.rightButtonEnabled,
    })
    this.setState({ rightButtonEnabled: !this.state.rightButtonEnabled })
  }

  changeTitle() {
    this.props.garden.setTitleItem({ title: this.state.title })
    this.setState({
      title: this.state.title === 'Options' ? '配置' : 'Options',
    })
  }

  passOptions() {
    this.props.navigator.push('PassOptions', {}, { titleItem: { title: 'The Passing Title' } })
  }

  switchTab() {
    this.props.navigator.switchTab(0)
  }

  toggleTabBadge() {
    if (this.state.badge) {
      this.setState({ badge: null })
      this.props.garden.setTabBadge([
        { index: 0, hidden: true },
        { index: 1, hidden: true },
      ])
    } else {
      this.setState({ badge: '5' })
      this.props.garden.setTabBadge([
        { index: 0, hidden: false, dot: true },
        { index: 1, hidden: false, text: '99' },
      ])
    }
  }

  topBarMisc() {
    this.props.navigator.push('TopBarMisc')
  }

  lifecycle() {
    this.props.navigator.push('Lifecycle')
  }

  replaceTabIcon() {
    if (this.icon === 'flower') {
      this.icon = ''
      this.props.garden.setTabIcon({
        index: 1,
        icon: Image.resolveAssetSource(require('./images/flower_1.png')),
      })
    } else {
      this.icon = 'flower'
      this.props.garden.setTabIcon({
        index: 1,
        icon: { uri: 'flower', scale: PixelRatio.get() },
      })
    }
  }

  replaceTabItemColor() {
    if (this.tabItemColor === '#8BC34A') {
      this.tabItemColor = '#FF5722'
      this.props.garden.updateTabBar({
        tabBarItemColor: '#FF5722',
        tabBarUnselectedItemColor: '#BDBDBD',
      })
    } else {
      this.tabItemColor = '#8BC34A'
      this.props.garden.updateTabBar({
        tabBarItemColor: '#8BC34A',
        tabBarUnselectedItemColor: '#BDBDBD',
      })
    }
  }

  setTabBarColor() {
    if (this.tabBarColor === '#EEEEEE') {
      this.tabBarColor = '#FFFFFF'
      this.props.garden.updateTabBar({
        tabBarColor: '#FFFFFF',
        tabBarShadowImage: {
          color: '#F0F0F0',
        },
      })
    } else {
      this.tabBarColor = '#EEEEEE'
      this.props.garden.updateTabBar({
        tabBarColor: '#EEEEEE',
        tabBarShadowImage: {
          image: Image.resolveAssetSource(require('./images/divider.png')),
        },
      })
    }
  }

  async changeTabBar() {
    await Navigator.setRoot(getLayout())
    console.log('finish setRoot!!')
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
        <View style={styles.container}>
          <Text style={styles.welcome}>This's a React Native scene.</Text>

          <TouchableOpacity onPress={this.topBarMisc} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>topBar options</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.lifecycle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>Lifecycle</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.passOptions} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>pass options to another scene</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.changeLeftButton}
            activeOpacity={0.2}
            style={styles.button}>
            <Text style={styles.buttonText}>
              {this.state.leftButtonShowText
                ? 'change left button to text'
                : 'change left button to icon'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.changeRightButton}
            activeOpacity={0.2}
            style={styles.button}>
            <Text style={styles.buttonText}>
              {this.state.rightButtonEnabled ? 'disable right button' : 'enable right button'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.changeTitle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>{`change title to '${this.state.title}'`}</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.switchTab} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>switch to tab 'Navigation'</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.toggleTabBadge} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>
              {this.state.badge ? 'hide tab badge' : 'show tab badge'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.replaceTabIcon} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>replalce tab icon</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.replaceTabItemColor}
            activeOpacity={0.2}
            style={styles.button}>
            <Text style={styles.buttonText}>replalce tab item color</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.setTabBarColor} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>change tab bar color</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.changeTabBar} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>change TabBar</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    )
  }
}
