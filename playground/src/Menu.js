import React, { Component } from 'react';
import {
	TouchableOpacity,
	StyleSheet,
	Text,
	View,
} from 'react-native';

import styles from './Styles'

const REQUEST_CODE = 1;

export default class Menu extends Component {

	constructor(props){
		super(props);
		this.push = this.push.bind(this);
		this.present = this.present.bind(this);
		this.switchToTab = this.switchToTab.bind(this);
	}

	push() {
    this.props.navigator.closeMenu();
		this.props.navigator.push('ReactNavigation');
	}

	present() {
    this.props.navigator.closeMenu();
		this.props.navigator.present('ReactResult', REQUEST_CODE);
	}

	switchToTab() {
    this.props.navigator.closeMenu();
		this.props.navigator.switchToTab(1);
  }

	render() {
		return (
			<View style={styles.container}>
				<Text style={[styles.welcome, {marginTop: 80}]}>
					This's a React Native Menu.
        </Text>

				<TouchableOpacity onPress={this.push} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						push
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.present} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						present 
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.switchToTab} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						switch to tab 'Style'
          </Text>
				</TouchableOpacity>

			</View>
		);
	}
}