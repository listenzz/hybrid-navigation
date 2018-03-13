/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { TouchableOpacity, Text, View, Image, ScrollView, PixelRatio } from 'react-native';

import styles from './Styles';
import fontUri from './FontUtil';

export default class Options extends Component {
  static navigationItem = {
    titleItem: {
      title: 'Options',
    },

    leftBarButtonItem: {
      // icon: { uri: fontUri('FontAwesome', 'navicon', 24)},
      title: 'Menu',
      action: navigation => {
        navigation.toggleMenu();
      },
    },

    rightBarButtonItem: {
      icon: Image.resolveAssetSource(require('./images/ic_settings.png')),
      title: 'SETTING',
      action: navigation => {
        console.info('setting button is clicked.');
      },
      enabled: false,
    },

    tabItem: {
      title: 'Options',
      icon: { uri: fontUri('FontAwesome', 'leaf', 24) },
      hideTabBarWhenPush: true,
    },
  };

  constructor(props) {
    super(props);
    this.changeLeftButton = this.changeLeftButton.bind(this);
    this.changeRightButton = this.changeRightButton.bind(this);
    this.changeTitle = this.changeTitle.bind(this);
    this.topBarMisc = this.topBarMisc.bind(this);
    this.passOptions = this.passOptions.bind(this);
    this.switchToTab = this.switchToTab.bind(this);
    this.toggleTabBadge = this.toggleTabBadge.bind(this);
    this.lifecycle = this.lifecycle.bind(this);
    this.state = {
      leftButtonShowText: true,
      rightButtonEnabled: false,
      title: '配置',
      badge: null,
    };
  }

  changeLeftButton() {
    if (this.state.leftButtonShowText) {
      this.props.garden.setLeftBarButtonItem({
        icon: { uri: fontUri('FontAwesome', 'navicon', 24) },
        // icon: { uri: 'flower', scale: PixelRatio.get() },
      });
    } else {
      this.props.garden.setLeftBarButtonItem({ icon: null });
    }
    this.setState({ leftButtonShowText: !this.state.leftButtonShowText });
  }

  changeRightButton() {
    this.props.garden.setRightBarButtonItem({
      enabled: !this.state.rightButtonEnabled,
    });
    this.setState({ rightButtonEnabled: !this.state.rightButtonEnabled });
  }

  changeTitle() {
    this.props.garden.setTitleItem({ title: this.state.title });
    this.setState({ title: this.state.title === 'Options' ? '配置' : 'Options' });
  }

  passOptions() {
    this.props.navigation.push('PassOptions', {}, { titleItem: { title: 'The Passing Title' } });
  }

  switchToTab() {
    this.props.navigation.switchToTab(0);
  }

  toggleTabBadge() {
    if (this.state.badge) {
      this.setState({ badge: null });
      this.props.navigation.setTabBadge(1, null);
    } else {
      this.setState({ badge: '5' });
      this.props.navigation.setTabBadge(1, '99');
    }
  }

  topBarMisc() {
    this.props.navigation.push('TopBarMisc');
  }

  lifecycle() {
    this.props.navigation.push('Lifecycle');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
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
            style={styles.button}
          >
            <Text style={styles.buttonText}>
              {this.state.leftButtonShowText
                ? 'change left button to icon'
                : 'change left button to text'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.changeRightButton}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>
              {this.state.rightButtonEnabled ? 'disable right button' : 'enable right button'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.changeTitle} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>{`change title to '${this.state.title}'`}</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.toggleTabBadge} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>
              {this.state.badge ? 'hide tab badge' : 'show tab badge'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.switchToTab} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>switch to tab 'Navigation'</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
