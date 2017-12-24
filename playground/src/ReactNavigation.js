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

import { RESULT_OK } from 'react-native-navigation-hybrid'

const REQUEST_CODE = 1;

export default class ReactNavigation extends Component {

	static navigationItem = {
		titleItem: {
			title: 'RN navigation',
		}
	}

	constructor(props){
		super(props);
		this.pushToNative = this.pushToNative.bind(this);
		this.pushToReact = this.pushToReact.bind(this);
		this.popToRoot = this.popToRoot.bind(this);
		this.requestFromNative = this.requestFromNative.bind(this);
		this.requestFromReact = this.requestFromReact.bind(this);
		this.replaceWithNative = this.replaceWithNative.bind(this);
		this.state = {
			text: undefined,
			error: undefined,
			isRoot: false,
		}
	}

	componentWillMount() {
		console.log('componentWillMount=' + this.props.sceneId );
		this.props.navigator.isRoot().then((isRoot) => {
			if(isRoot) {
				this.setState({isRoot});
			}
		});
	}

	componentDidMount() {
		console.log('componentDidMount =' + this.props.sceneId);
	}

	componentWillUnmount() {
		console.log('componentWillUnmount=' + this.props.sceneId);
	}

	onComponentResult(requestCode, resultCode, data) {
		console.info('----------resultCode:' + resultCode);
		if(requestCode === REQUEST_CODE) {
			if(resultCode === RESULT_OK) {
				this.setState({text: data.text || '', error: undefined});
			} else {
				this.setState({text: undefined, error: 'ACTION CANCEL'});
			}
		}
	}

	pushToNative() {
		this.props.navigator.push('NativeNavigation');
	}

	pushToReact() {
		this.props.navigator.push('ReactNavigation');
	}

	popToRoot() {
		this.props.navigator.popToRoot();
	}

	replaceWithNative() {
		this.props.navigator.replace("NativeNavigation");
	}

	requestFromReact() {
		this.props.navigator.present("ReactResult", REQUEST_CODE);
	}

	requestFromNative() {
		this.props.navigator.present("NativeResult", REQUEST_CODE);
	}

	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.welcome}>
					这是一个 React Native 页面
        		</Text>

				<TouchableOpacity onPress={this.pushToNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						push 到原生页面
          			</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={this.pushToReact} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						push 到 RN 页面
          			</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.replaceWithNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						replace 为原生页面
          			</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.popToRoot} activeOpacity={0.2} style={styles.button} disabled={this.state.isRoot}>
					<Text style={this.state.isRoot ? styles.buttonTextDisable : styles.buttonText}>
						popToRoot
          			</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.requestFromReact} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						请求 React Native 返回结果
          			</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.requestFromNative} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						请求 native 返回结果
          			</Text>
				</TouchableOpacity>

				{this.state.text !== undefined && 
					(<Text style={styles.result}>
							返回的结果：{this.state.text}
					</Text>)
				}
			
				{this.state.error !== undefined && 
					(<Text style={styles.result}>
						{this.state.error}
					</Text>)
				}

			</View>
		);
	}
}