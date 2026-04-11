import React from 'react';
import { Text, View } from 'react-native';
import { NavigationProps, useVisibleEffect } from 'hybrid-navigation';

import styles from './Styles';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function Menu({ navigator }: NavigationProps) {
	const inset = useSafeAreaInsets();

	useVisibleEffect(() => {
		console.log('Menu is visible');
		return () => console.log('Menu is invisible');
	});

	return (
		<View style={[styles.container, { paddingTop: inset.top }]}>
			<Text style={styles.welcome}>This's a React Native Menu.</Text>
		</View>
	);
}
