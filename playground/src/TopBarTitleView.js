import React, { Component } from 'react';
import { Text, View, TouchableOpacity, ScrollView, Alert, Image } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

import styles from './Styles';

class CustomTitleView extends Component {
  render() {
    let { params } = this.props.navigation.state;
    return (
      <View
        style={{
          flex: 1,
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        <Text style={styles.welcome}>--标题--</Text>
        <Icon.Button
          name="facebook"
          backgroundColor="#3b5998"
          onPress={params.onFackbookButtonClick}
        />
      </View>
    );
  }
}

export { CustomTitleView };

export default class TopBarTitleView extends Component {
  static navigationItem = {
    backButtonHidden: true,
    titleItem: {
      title: '出 BUG 了',
      moduleName: 'CustomTitleView', // registered component name
      layoutFitting: 'expanded', // expanded or compressed, default is compressed
    },
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
    this.topBarHidden = this.topBarHidden.bind(this);
    this.topBarColor = this.topBarColor.bind(this);
    this.topBarAlpha = this.topBarAlpha.bind(this);
    this.props.navigation.setParams({
      onFackbookButtonClick: this.onFackbookButtonClick.bind(this),
    });
  }

  onFackbookButtonClick() {
    Alert.alert(
      'Hello!',
      'Fackbook button is clicked.',
      [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
      { cancelable: false }
    );
  }

  topBarHidden() {
    this.props.navigation.push('TopBarHidden');
  }

  topBarColor() {
    this.props.navigation.push('TopBarColor');
  }

  topBarAlpha() {
    this.props.navigation.push('TopBarAlpha');
  }

  topBarTitleView() {
    this.props.navigation.push('TopBarTitleView');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}> 自定义标题栏 </Text>

          <TouchableOpacity onPress={this.topBarHidden} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar hidden</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarColor} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar color</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={this.topBarAlpha} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBar alpha</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.topBarTitleView}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>TopBar title view</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
