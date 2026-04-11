import React from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import { SafeAreaView } from 'react-native-safe-area-context';
import styles from './Styles';

export default withNavigationItem({
	statusBarHidden: true,
})(StatusBarHidden);

function StatusBarHidden({ navigator, sceneId }: NavigationProps) {
	function statusBarHiddenPage() {
		navigator.push('StatusBarHidden');
	}

	function showStatusBar() {
		Navigation.updateOptions(sceneId, { statusBarHidden: false });
	}

	function hideStatusBar() {
		Navigation.updateOptions(sceneId, { statusBarHidden: true });
	}

	return (
		<SafeAreaView style={{ flex: 1 }} edges={['top', 'bottom']}>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>StatusBar Hidden</Text>
					<TouchableOpacity onPress={showStatusBar} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>show status bar</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={hideStatusBar} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>hide status bar</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={statusBarHiddenPage} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>push StatusBarHidden</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</SafeAreaView>
	);
}
