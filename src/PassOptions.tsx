import React from 'react';
import { Text, View, ScrollView } from 'react-native';
import { withNavigationItem } from 'hybrid-navigation';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import styles from './Styles';

export default withNavigationItem({
	titleItem: {
		title: 'The Origin Title',
	},
})(PassOptions);

function PassOptions() {
	const insets = useSafeAreaInsets();

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={true}
			contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
		>
			<View style={[styles.container, { paddingTop: insets.top }]}>
				<Text style={styles.welcome}>Attention: the title is not 'The Origin Title'</Text>
			</View>
		</ScrollView>
	);
}
