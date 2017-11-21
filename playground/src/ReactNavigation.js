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
	View
} from 'react-native';

import styles from './Styles'

export default class ReactNavigation extends Component {

	constructor(props){
		super(props);
		this.pushToNative = this.pushToNative.bind(this);
		this.pushToReact = this.pushToReact.bind(this);
		this.popToRoot = this.popToRoot.bind(this);
		this.requestFromNative = this.requestFromNative.bind(this);
		this.requestFromReact = this.requestFromReact.bind(this);
	}

	pushToNative() {
		console.warn("-------哈哈哈哈-----");
	}

	pushToReact() {

	}

	popToRoot() {

	}

	requestFromReact() {

	}

	requestFromNative() {

	}

	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.welcome}>
					这是一个 React Native 页面：
        </Text>

				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						push 到原生页面
          </Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						push 到 RN 页面
          </Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						popToRoot
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						请求 React Native 返回结果
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						请求 native 返回结果
          </Text>
				</TouchableOpacity>

				<Text style={styles.result}>
					 结果
        </Text>
				
			</View>
		);
	}
}