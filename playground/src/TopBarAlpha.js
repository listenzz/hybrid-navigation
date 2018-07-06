import React, { Component } from 'react';
import {
  Text,
  View,
  TouchableOpacity,
  ScrollView,
  Slider,
  Image,
  Alert,
  StatusBar,
  Platform,
} from 'react-native';
import { ifIphoneX } from 'react-native-iphone-x-helper';
import { Garden } from 'react-native-navigation-hybrid';
import styles from './Styles';

function ifKitKat(obj1 = {}, obj2 = {}) {
  return Platform.Version > 18 ? obj1 : obj2;
}

const paddingTop = Platform.select({
  ios: {
    ...ifIphoneX(
      {
        paddingTop: 8 + 44,
      },
      {
        paddingTop: 8 + 20,
      }
    ),
  },
  android: {
    ...ifKitKat(
      {
        paddingTop: 12 + StatusBar.currentHeight,
      },
      {
        paddingTop: 12,
      }
    ),
  },
});

export default class TopBarAlpha extends Component {
  static navigationItem = {
    topBarAlpha: 0.5,
    extendedLayoutIncludesTopBar: true,
    // titleItem: {
    //   title: '出 BUG 了',
    //   moduleName: 'CustomTitleView',
    //   layoutFitting: 'compressed', // expanded or compressed, default is compressed
    // },
    rightBarButtonItem: {
      icon: Image.resolveAssetSource(require('./images/ic_settings.png')),
      title: 'SETTING',
      action: navigator => {
        console.info('setting button is clicked.');
      },
    },
  };

  constructor(props) {
    super(props);
    this.topBarTitleView = this.topBarTitleView.bind(this);
    this.topBarHidden = this.topBarHidden.bind(this);
    this.topBarColor = this.topBarColor.bind(this);
    this.topBarAlpha = this.topBarAlpha.bind(this);
    this.onAlphaChange = this.onAlphaChange.bind(this);
    this.props.navigator.setParams({
      onFackbookButtonClick: this.onFackbookButtonClick.bind(this),
    });
    this.state = { alpha: 0.5 };
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
    this.props.navigator.push('TopBarHidden');
  }

  topBarColor() {
    this.props.navigator.push('TopBarColor');
  }

  topBarAlpha() {
    this.props.navigator.push('TopBarAlpha');
  }

  topBarTitleView() {
    this.props.navigator.push('TopBarTitleView');
  }

  onAlphaChange(value) {
    this.props.garden.setTopBarAlpha({
      topBarAlpha: value,
    });
    this.setState({ alpha: value });
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={[styles.container, paddingTop]}>
          <Text style={styles.welcome}>滑动看看</Text>

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

          <Slider
            style={{ marginLeft: 32, marginRight: 32 }}
            onValueChange={this.onAlphaChange}
            step={0.01}
            value={this.state.alpha}
          />

          <Text style={styles.result}>alpha: {this.state.alpha}</Text>
        </View>
      </ScrollView>
    );
  }
}
