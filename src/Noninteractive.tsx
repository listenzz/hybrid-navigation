import React, { useState } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default withNavigationItem({
	backInteractive: false,
})(Noninteractive);

function Noninteractive({ navigator, sceneId }: NavigationProps) {
	const [backInteractive, setBackInteractive] = useState(false);

	function handleBackClick() {
		navigator.pop();
	}

	function enableBackInteractive() {
		Navigation.updateOptions(sceneId, {
			backInteractive: true,
		});
		setBackInteractive(true);
	}

	function disableBackInteractive() {
		Navigation.updateOptions(sceneId, {
			backInteractive: false,
		});
		setBackInteractive(false);
	}

	let component = null;

	if (backInteractive) {
		component = (
			<>
				<Text style={styles.welcome}>Now you can back via any way</Text>
				<TouchableOpacity onPress={disableBackInteractive} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>disable back interactive</Text>
				</TouchableOpacity>
			</>
		);
	} else {
		component = (
			<>
				<Text style={styles.welcome}>Now you can only back via the button below</Text>
				<TouchableOpacity onPress={handleBackClick} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>back</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={enableBackInteractive} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>enable back interactive</Text>
				</TouchableOpacity>
			</>
		);
	}

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar title="Noninteractive" navigator={navigator} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>{component}</View>
			</ScrollView>
		</View>
	);
}
