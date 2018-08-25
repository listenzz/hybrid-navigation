import React, { Component } from 'react';
import { Text, View, ScrollView, Switch, TouchableOpacity } from 'react-native';

import styles from './Styles';

export default class TopBarShadowHidden extends Component {
  static navigationItem = {
    topBarShadowHidden: true,
    titleItem: {
      title: 'Hide Shadow',
    },
  };

  constructor(props) {
    super(props);
    this.onHiddenChange = this.onHiddenChange.bind(this);
    this.state = {
      hidden: true,
    };
  }

  onHiddenChange(value) {
    this.setState({ hidden: value });
    this.props.garden.setTopBarShadowHidden({ topBarShadowHidden: value });
  }

  topBarAlpha() {
    this.props.navigator.push('TopBarAlpha');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}>
            {this.state.hidden ? 'topBar shadow is hidden' : 'topBar shadow is visible'}
          </Text>
        </View>

        <View style={styles.button}>
          <Switch onValueChange={this.onHiddenChange} value={this.state.hidden} />
        </View>
      </ScrollView>
    );
  }
}
