import React from 'react';
import { Text, View, ScrollView } from 'react-native';
import { NavigationProps } from 'hybrid-navigation';

import styles from './Styles';
import TopBar from './TopBar';

export default function PassOptions({ navigator }: NavigationProps) {
	return (
		<View style={{ flex: 1 }}>
			<TopBar title="Pass Options" navigator={navigator} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>This screen now uses the shared RN TopBar.</Text>
				</View>
			</ScrollView>
		</View>
	);
}
