import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

import styles from './Styles';

export default class Noninteractive extends Component {
  static navigationItem = {
    // backButtonHidden: true,
    // swipeBackEnabled: false,
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
    this.props.navigator.pop();
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>Now you can only back via the button below</Text>

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
