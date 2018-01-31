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
	TextInput,
} from 'react-native';

import styles from './Styles'

import { RESULT_OK } from 'react-native-navigation-hybrid'

export default class ReactResult extends Component {

	static navigationItem = {

		titleItem: {
			title: 'RN result',
		},

	}

	constructor(props) {
		super(props);
		this.popToRoot = this.popToRoot.bind(this);
    this.pushToReact = this.pushToReact.bind(this);
		this.sendResult = this.sendResult.bind(this);
		this.onInputTextChanged = this.onInputTextChanged.bind(this);
		this.state = {
			text: '',
			isRoot: false,
		}
	}

	componentWillMount() {
		this.props.navigator.isRoot().then((isRoot) => {
			if(isRoot) {
				this.props.garden.setLeftBarButtonItem({
					title: 'Cancel', 
					insets: {top: -1, left: -8, bottom: 0, right: 8},
					action: 'cancel'
				});
				this.setState({isRoot: isRoot})
			}
		})
	}

	onBarButtonItemClick(action) {
		if (action === 'cancel') {
			this.props.navigator.dismiss();
		}
	}

	popToRoot() {
		this.props.navigator.popToRoot();
	}

	pushToReact() {
		this.props.navigator.push('ReactResult');
  }
  
	sendResult() {
    this.props.navigator.setResult(RESULT_OK, {text: this.state.text, backId: this.props.sceneId})
		this.props.navigator.dismiss();
  }

	onInputTextChanged(text) {
		this.setState({text: text})
	}
    
	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.welcome}>
					This's a React Native scene.
        </Text>

				<TouchableOpacity onPress={this.pushToReact} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						push to another scene
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.popToRoot} activeOpacity={0.2} style={styles.button} disabled={this.state.isRoot}>
					<Text style={this.state.isRoot ? styles.buttonTextDisable : styles.buttonText}>
						pop to home
          </Text>
				</TouchableOpacity>

				<TextInput style={styles.input} 
					onChangeText={this.onInputTextChanged} 
					value={this.state.text} 
					placeholder={'enter your text'} 
					underlineColorAndroid='#00000000' 
					textAlignVertical="center"/>

				<TouchableOpacity onPress={this.sendResult} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						send data back
          </Text>
				</TouchableOpacity>

			</View>
		);
	}
}