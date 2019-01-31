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
    rightBarButtonItem: {
      icon: Image.resolveAssetSource(require('./images/ic_settings.png')),
      title: 'SETTING',
      action: navigator => {
        navigator.push('TopBarMisc');
      },
    },
  };

  constructor(props) {
    super(props);
    this.topBarAlpha = this.topBarAlpha.bind(this);
    this.onAlphaChange = this.onAlphaChange.bind(this);
    let alpha = props.alpha ? Number(props.alpha) : 0.5;
    let topBarColor = props.color || '#FFFFFF';
    this.state = { alpha };
    if (alpha !== 0.5 || topBarColor !== '#FFFFFF') {
      this.props.garden.updateTopBar({
        topBarAlpha: alpha,
        topBarColor: topBarColor,
      });
    }
  }

  topBarAlpha() {
    this.props.navigator.push('TopBarAlpha');
  }

  onAlphaChange(value) {
    this.props.garden.updateTopBar({
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
          <Text style={styles.welcome}>Try to slide</Text>

          <Slider
            style={{ marginLeft: 32, marginRight: 32, marginTop: 40 }}
            onValueChange={this.onAlphaChange}
            step={0.01}
            value={this.state.alpha}
          />

          <Text style={styles.result}>alpha: {this.state.alpha}</Text>

          <TouchableOpacity onPress={this.topBarAlpha} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBarAlpha</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }
}
