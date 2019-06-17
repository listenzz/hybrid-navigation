import React, { Component } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

import styles from './Styles';

export default class Noninteractive extends Component {
  static navigationItem = {
    backButtonHidden: true,
    // swipeBackEnabled: false,
    backInteractive: false,
    titleItem: {
      title: 'Noninteractive',
    },
  };

  constructor(props) {
    super(props);
    this.onBackButtonClick = this.onBackButtonClick.bind(this);
    this.enableBackInteractive = this.enableBackInteractive.bind(this);
    this.disableBackInteractive = this.disableBackInteractive.bind(this);
    this.state = { backInteractive: false };
  }

  onBackButtonClick() {
    this.props.navigator.pop();
  }

  enableBackInteractive() {
    this.props.garden.updateTopBar({
      backButtonHidden: false,
      backInteractive: true,
    });
    this.setState({
      backInteractive: true,
    });
  }

  disableBackInteractive() {
    this.props.garden.updateTopBar({
      backButtonHidden: true,
      backInteractive: false,
    });
    this.setState({
      backInteractive: false,
    });
  }

  render() {
    let component = null;

    if (this.state.backInteractive) {
      component = (
        <React.Fragment>
          <Text style={styles.welcome}>Now you can back via any way</Text>
          <TouchableOpacity
            onPress={this.disableBackInteractive}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>disable back interactive</Text>
          </TouchableOpacity>
        </React.Fragment>
      );
    } else {
      component = (
        <React.Fragment>
          <Text style={styles.welcome}>Now you can only back via the button below</Text>
          <TouchableOpacity
            onPress={this.onBackButtonClick}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>back</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={this.enableBackInteractive}
            activeOpacity={0.2}
            style={styles.button}
          >
            <Text style={styles.buttonText}>enable back interactive</Text>
          </TouchableOpacity>
        </React.Fragment>
      );
    }

    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
      >
        <View style={styles.container}>{component}</View>
      </ScrollView>
    );
  }
}
