import React, {useCallback} from 'react';
import {TouchableOpacity, Text, View} from 'react-native';
import {NavigationProps, topBarHeight, useVisibleEffect} from 'hybrid-navigation';

import styles from './Styles';

export default function Menu({navigator}: NavigationProps) {
	const push = () => {
		navigator.closeMenu();
		navigator.push('NativeModule');
	};

	function pushToRedux() {
		navigator.closeMenu();
		navigator.push('ReduxCounter');
	}

	function pushToZustand() {
		navigator.closeMenu();
		navigator.push('ZustandCounter');
	}

	function pushToToast() {
		navigator.closeMenu();
		navigator.push('Toast');
	}

	function backgroundTask() {
		navigator.closeMenu();
		navigator.push('BackgroundTaskDemo');
	}

	useVisibleEffect(
		useCallback(() => {
			console.log('Menu is visible');
			return () => console.log('Menu is invisible');
		}, []),
	);

	return (
		<View style={[styles.container, {paddingTop: topBarHeight()}]}>
			<Text style={styles.welcome}>This's a React Native Menu.</Text>

			<TouchableOpacity onPress={push} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}>push to native</Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={pushToRedux} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}>Redux Counter</Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={pushToZustand} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}>Zustand Counter</Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={pushToToast} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}>Toast</Text>
			</TouchableOpacity>
			<TouchableOpacity onPress={backgroundTask} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}>BackgroundTask</Text>
			</TouchableOpacity>
		</View>
	);
}
