import React, { useCallback } from 'react';
import { TouchableOpacity, Text, View } from 'react-native';
import { NavigationProps, useVisibleEffect } from 'hybrid-navigation';

import styles from './Styles';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function Menu({ navigator }: NavigationProps) {
	const inset = useSafeAreaInsets();

	const push = () => {
		navigator.closeMenu();
		navigator.push('NativeModule');
	};

	useVisibleEffect(
		useCallback(() => {
			console.log('Menu is visible');
			return () => console.log('Menu is invisible');
		}, []),
	);

	return (
		<View style={[styles.container, { paddingTop: inset.top }]}>
			<Text style={styles.welcome}>This's a React Native Menu.</Text>

			<TouchableOpacity onPress={push} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}>push to native</Text>
			</TouchableOpacity>
		</View>
	);
}
