import React from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

function TopBarHidden({ navigator }: NavigationProps) {
	const insets = useSafeAreaInsets();
	function topBarHidden() {
		navigator.push('TopBarHidden');
	}

	function options() {
		navigator.push('Options');
	}

	return (
		<ScrollView>
			<View style={[styles.container, { paddingTop: insets.top }]}>
				<Text style={styles.welcome}>TopBar is hidden</Text>
				<TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>TopBarHidden</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={options} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>Options</Text>
				</TouchableOpacity>
			</View>
		</ScrollView>
	);
}

export default withNavigationItem({
	screenBackgroundColor: '#F8F8F8',
	topBarHidden: true,
	titleItem: {
		title: 'You can not see me',
	},
})(TopBarHidden);
