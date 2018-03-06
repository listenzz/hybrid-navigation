/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView, SafeAreaView } from 'react-native';

import styles from './Styles';
import { RESULT_OK } from 'react-native-navigation-hybrid';
import fontUri from './FontUtil';

const REQUEST_CODE = 1;

export default class Navigation extends Component {
  static navigationItem = {
    titleItem: {
      title: 'RN navigation',
    },

    tabItem: {
      title: 'Navigation',
      icon: { uri: fontUri('FontAwesome', 'location-arrow', 24) },
      hideTabBarWhenPush: true,
    },
  };

  constructor(props) {
    super(props);
    this.push = this.push.bind(this);
    this.pop = this.pop.bind(this);
    this.popTo = this.popTo.bind(this);
    this.popToRoot = this.popToRoot.bind(this);
    this.replace = this.replace.bind(this);
    this.replaceToRoot = this.replaceToRoot.bind(this);
    this.present = this.present.bind(this);
    this.switchToTab = this.switchToTab.bind(this);
    this.state = {
      text: undefined,
      backId: undefined,
      error: undefined,
      isRoot: false,
    };
  }

  componentWillMount() {
    this.props.navigator.onComponentResult = this.onComponentResult.bind(this);
    this.props.navigator.isRoot().then(isRoot => {
      if (isRoot) {
        this.setState({ isRoot });
      }
    });
  }

  onComponentResult(requestCode, resultCode, data) {
    if (requestCode === REQUEST_CODE) {
      if (resultCode === RESULT_OK) {
        this.setState({
          text: data.text || '',
          error: undefined,
          backId: data.backId || undefined,
        });
      } else {
        this.setState({ text: undefined, error: 'ACTION CANCEL' });
      }
    } else if (requestCode === 0) {
      if (resultCode === RESULT_OK) {
        this.setState({ backId: data.backId || undefined });
      }
    }
  }

  push() {
    if (!this.state.isRoot) {
      if (this.props.popToId !== undefined) {
        this.props.navigator.push('Navigation', {
          popToId: this.props.popToId,
        });
      } else {
        this.props.navigator.push('Navigation', {
          popToId: this.props.sceneId,
        });
      }
    } else {
      this.props.navigator.push('Navigation');
    }
  }

  pop() {
    this.props.navigator.setResult(RESULT_OK, { backId: this.props.sceneId });
    this.props.navigator.pop();
  }

  popTo() {
    this.props.navigator.setResult(RESULT_OK, { backId: this.props.sceneId });
    this.props.navigator.popTo(this.props.popToId);
  }

  popToRoot() {
    this.props.navigator.setResult(RESULT_OK, { backId: this.props.sceneId });
    this.props.navigator.popToRoot();
  }

  replace() {
    this.props.navigator.replace('Navigation');
  }

  replaceToRoot() {
    this.props.navigator.replaceToRoot('Navigation');
  }

  present() {
    this.props.navigator.present('Result', REQUEST_CODE);
  }

  switchToTab() {
    this.props.navigator.switchToTab(1);
  }

  render() {
    return (
      <SafeAreaView style={styles.safeArea}>
        <ScrollView contentInsetAdjustmentBehavior="never">
          <View style={styles.container}>
            <Text style={styles.welcome}>This's a React Native scene.</Text>

            <TouchableOpacity onPress={this.push} activeOpacity={0.2} style={styles.button}>
              <Text style={styles.buttonText}>push</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={this.pop}
              activeOpacity={0.2}
              style={styles.button}
              disabled={this.state.isRoot}
            >
              <Text style={this.state.isRoot ? styles.buttonTextDisable : styles.buttonText}>
                pop
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={this.popTo}
              activeOpacity={0.2}
              style={styles.button}
              disabled={this.props.popToId == undefined}
            >
              <Text
                style={
                  this.props.popToId == undefined ? styles.buttonTextDisable : styles.buttonText
                }
              >
                popTo last but one
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={this.popToRoot}
              activeOpacity={0.2}
              style={styles.button}
              disabled={this.state.isRoot}
            >
              <Text style={this.state.isRoot ? styles.buttonTextDisable : styles.buttonText}>
                popToRoot
              </Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={this.replace} activeOpacity={0.2} style={styles.button}>
              <Text style={styles.buttonText}>replace</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={this.replaceToRoot}
              activeOpacity={0.2}
              style={styles.button}
            >
              <Text style={styles.buttonText}>replaceToRoot</Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={this.present} activeOpacity={0.2} style={styles.button}>
              <Text style={styles.buttonText}>present</Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={this.switchToTab} activeOpacity={0.2} style={styles.button}>
              <Text style={styles.buttonText}>switch to tab 'Style'</Text>
            </TouchableOpacity>

            {this.state.text !== undefined && (
              <Text style={styles.result}>received text：{this.state.text}</Text>
            )}

            {this.state.error !== undefined && (
              <Text style={styles.result}>{this.state.error}</Text>
            )}
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }
}
