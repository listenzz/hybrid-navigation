import React, { Component } from 'react';
import { Text, View, TouchableOpacity, ScrollView, Alert, Image } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

import styles from './Styles';

class CustomTitleView extends Component {
  render() {
    let { params } = this.props.navigator.state;
    return (
      <View
        style={{
          flex: 1,
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        <Text style={styles.welcome}>--Custom Title--</Text>
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
      moduleName: 'CustomTitleView', // registered component name
      layoutFitting: 'expanded', // expanded or compressed, default is compressed
    },
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
    this.props.navigator.setParams({
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

  topBarTitleView() {
    this.props.navigator.push('TopBarTitleView');
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>
          <Text style={styles.welcome}> Custom title bar </Text>

          <TouchableOpacity
            onPress={this.topBarTitleView}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>TopBarTitleView</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
