/**
 * Sample React Native ReactNavigation
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
	TouchableOpacity,
	StyleSheet,
	Text,
	View,
    TextInput
} from 'react-native';

import styles from './Styles'

import { RESULT_OK } from 'react-native-navigation-hybrid'

export default class ReactResult extends Component {

	constructor(props){
		super(props);
		this.pushToNative = this.pushToNative.bind(this);
		this.pushToReact = this.pushToReact.bind(this);
        this.sendResult = this.sendResult.bind(this);
        this.onInputTextChanged = this.onInputTextChanged.bind(this);

		this.state = {
			text: '',
		}
	}

	pushToNative() {
		this.props.navigator.push('NativeResult');
	}

	pushToReact() {
		this.props.navigator.push('ReactResult');
	}

	sendResult() {
        this.props.navigator.setResult(RESULT_OK, {text: this.state.text})
		this.props.navigator.dismiss();
    }

    onInputTextChanged(text) {
        this.setState({text: text})
    }
    
	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.welcome}>
					这是一个 React Native 页面：
        		</Text>

                <TextInput style={styles.input} onChangeText={this.onInputTextChanged} value={this.state.text}/>

				<TouchableOpacity onPress={this.sendResult} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						返回结果
          			</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={this.pushToReact} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						到另一个 React Native 页面
          			</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						到 native 页面
          			</Text>
				</TouchableOpacity>
			</View>
		);
	}
}