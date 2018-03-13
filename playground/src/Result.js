/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import React, { Component } from 'react';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import { TouchableOpacity, Text, View, TextInput } from 'react-native';

import styles from './Styles';

import { RESULT_OK } from 'react-native-navigation-hybrid';

export default class Result extends Component {
  static navigationItem = {
    titleItem: {
      title: 'RN result',
    },
  };

  constructor(props) {
    super(props);
    this.popToRoot = this.popToRoot.bind(this);
    this.pushToReact = this.pushToReact.bind(this);
    this.sendResult = this.sendResult.bind(this);
    this.onInputTextChanged = this.onInputTextChanged.bind(this);
    this.state = {
      text: '',
      isRoot: false,
    };
  }

  componentWillMount() {
    this.props.navigation.isRoot().then(isRoot => {
      if (isRoot) {
        this.props.garden.setLeftBarButtonItem({
          title: 'Cancel',
          insets: { top: -1, left: -8, bottom: 0, right: 8 },
          action: navigation => {
            navigation.dismiss();
          },
        });
        this.setState({ isRoot: isRoot });
      }
    });
  }

  popToRoot() {
    this.props.navigation.popToRoot();
  }

  pushToReact() {
    this.props.navigation.push('Result');
  }

  sendResult() {
    this.props.navigation.setResult(RESULT_OK, {
      text: this.state.text,
      backId: this.props.sceneId,
    });
    this.props.navigation.dismiss();
  }

  onInputTextChanged(text) {
    this.setState({ text: text });
  }

  render() {
    return (
      <KeyboardAwareScrollView
        style={{ flex: 1 }}
        showsHorizontalScrollIndicator={false}
        contentInsetAdjustmentBehavior="automatic"
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>This's a React Native scene.</Text>

          <TouchableOpacity onPress={this.pushToReact} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>push to another scene</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.popToRoot}
            activeOpacity={0.2}
            style={styles.button}
            disabled={this.state.isRoot}
          >
            <Text style={this.state.isRoot ? styles.buttonTextDisable : styles.buttonText}>
              pop to home
            </Text>
          </TouchableOpacity>

          <TextInput
            style={styles.input}
            onChangeText={this.onInputTextChanged}
            value={this.state.text}
            placeholder={'enter your text'}
            underlineColorAndroid="#00000000"
            textAlignVertical="center"
          />

          <TouchableOpacity onPress={this.sendResult} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>send data back</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAwareScrollView>
    );
  }
}
