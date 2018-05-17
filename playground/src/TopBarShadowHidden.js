import React, { Component } from 'react';
import { Text, View, ScrollView, Switch, TouchableOpacity } from 'react-native';

import styles from './Styles';

export default class TopBarShadowHidden extends Component {
  static navigationItem = {
    // 注意这行代码，隐藏了 top bar 的阴影
    topBarShadowHidden: true,

    titleItem: {
      title: 'Hide Shadow',
    },
  };

  constructor(props) {
    super(props);
    this.onHiddenChange = this.onHiddenChange.bind(this);
    this.topBarAlpha = this.topBarAlpha.bind(this);
    this.state = {
      hidden: true,
    };
  }

  onHiddenChange(value) {
    this.setState({ hidden: value });
    this.props.garden.setTopBarShadowHidden({ topBarShadowHidden: value });
  }

  topBarAlpha() {
    this.props.navigation.push('TopBarAlpha');
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
            {this.state.hidden ? '看，TopBar 的阴影没有了。' : '看，TopBar 阴影又出来了'}
          </Text>
        </View>

        <View style={styles.button}>
          <Switch onValueChange={this.onHiddenChange} value={this.state.hidden} />
        </View>
        <TouchableOpacity onPress={this.topBarAlpha} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>TopBar alpha</Text>
        </TouchableOpacity>
      </ScrollView>
    );
  }
}
