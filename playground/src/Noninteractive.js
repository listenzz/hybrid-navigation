import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

import styles from './Styles';

export default class Noninteractive extends Component {
  static navigationItem = {
    // 注意这行代码，隐藏返回按钮
    backButtonHidden: true,
    // 不允许通过右滑（iOS）或者返回键（Android）返回
    backInteractive: false,

    titleItem: {
      title: 'Noninteractive',
    },
  };

  constructor(props) {
    super(props);
    this.onBackButtonClick = this.onBackButtonClick.bind(this);
  }

  onBackButtonClick() {
    this.props.navigation.pop();
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>现在，你只能通过下面的按钮返回</Text>

          <TouchableOpacity
            onPress={this.onBackButtonClick}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>back</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
