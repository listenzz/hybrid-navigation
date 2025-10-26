import React from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

function TopBarHidden({ navigator }: NavigationProps) {
	const inset = useSafeAreaInsets();
	function topBarHidden() {
		navigator.push('TopBarHidden');
	}

	return (
		<ScrollView>
			<View style={[styles.container, { paddingTop: inset.top }]}>
				<Text style={styles.welcome}>TopBar is hidden</Text>
				<TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>TopBarHidden</Text>
				</TouchableOpacity>
			</View>
		</ScrollView>
	);
}

export default withNavigationItem({
	screenBackgroundColor: '#FF0000',
	topBarHidden: true,
	titleItem: {
		title: 'You can not see me',
	},
})(TopBarHidden);
