import React, { Component } from 'react';
import {
	TouchableOpacity,
	StyleSheet,
	Text,
	View,
} from 'react-native';

import styles from './Styles'

export default class HideBackButton extends Component {

	static navigationItem = {
    // 注意这行代码，隐藏返回按钮
    hideBackButton: true,

		titleItem: {
			title: 'Hide Back Button',
		},
	}

	constructor(props) {
    super(props);
    this.onBackButtonClick = this.onBackButtonClick.bind(this);
	}

	onBackButtonClick() {
		this.props.navigator.pop();
	}
    
	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.welcome}>
					现在，你只能通过下面的按钮返回
        </Text>

				<TouchableOpacity onPress={this.onBackButtonClick} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						back
          </Text>
				</TouchableOpacity>
			</View>
		);
	}
}