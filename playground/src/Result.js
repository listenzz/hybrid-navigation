import React, { Component } from 'react';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import { TouchableOpacity, Text, View, TextInput, Platform } from 'react-native';
import styles from './Styles';

import { RESULT_OK, Navigator, BarStyleLightContent } from 'react-native-navigation-hybrid';

export default class Result extends Component {
  static navigationItem = {
    titleItem: {
      title: 'RN result',
    },
    topBarStyle: BarStyleLightContent,
    topBarTintColor: '#FFFFFF',
    ...Platform.select({
      ios: {
        topBarColor: '#FF344C',
      },
      android: {
        topBarColor: '#F94D53',
      },
    }),
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

  componentDidMount() {
    console.info('result componentDidMount');
  }

  componentDidAppear() {
    console.info('result componentDidAppear');
  }

  componentDidDisappear() {
    console.info('result componentDidDisappear');
  }

  componentWillUnmount() {
    console.info('result componentWillUnmount');
  }

  componentWillMount() {
    this.props.navigator.isStackRoot().then(isRoot => {
      if (isRoot) {
        this.props.garden.setLeftBarButtonItem({
          title: 'Cancel',
          insets: { top: -1, left: -8, bottom: 0, right: 8 },
          action: navigator => {
            navigator.dismiss();
          },
        });
        this.setState({ isRoot: isRoot });
      }
    });
  }

  popToRoot() {
    this.props.navigator.popToRoot();
  }

  pushToReact() {
    this.props.navigator.push('Result');
  }

  async sendResult() {
    let current = await Navigator.currentRoute();
    console.log(current);
    this.props.navigator.setResult(RESULT_OK, {
      text: this.state.text,
      backId: this.props.sceneId,
    });
    this.props.navigator.dismiss();
    current = await Navigator.currentRoute();
    console.log(current);
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
