import React, { useState } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default withNavigationItem({
	backButtonHidden: true,
	// swipeBackEnabled: false,
	backInteractive: false,
	titleItem: {
		title: 'Noninteractive',
	},
})(Noninteractive);

function Noninteractive({ navigator, sceneId }: NavigationProps) {
	const [backInteractive, setBackInteractive] = useState(false);
	const insets = useSafeAreaInsets();

	function handleBackClick() {
		navigator.pop();
	}

	function enableBackInteractive() {
		Navigation.updateOptions(sceneId, {
			backButtonHidden: false,
			backInteractive: true,
		});
		setBackInteractive(true);
	}

	function disableBackInteractive() {
		Navigation.updateOptions(sceneId, {
			backButtonHidden: true,
			backInteractive: false,
		});
		setBackInteractive(false);
	}

	let component = null;

	if (backInteractive) {
		component = (
			<>
				<Text style={styles.welcome}>Now you can back via any way</Text>
				<TouchableOpacity
					onPress={disableBackInteractive}
					activeOpacity={0.2}
					style={styles.button}
				>
					<Text style={styles.buttonText}>disable back interactive</Text>
				</TouchableOpacity>
			</>
		);
	} else {
		component = (
			<>
				<Text style={styles.welcome}>Now you can only back via the button below</Text>
				<TouchableOpacity
					onPress={handleBackClick}
					activeOpacity={0.2}
					style={styles.button}
				>
					<Text style={styles.buttonText}>back</Text>
				</TouchableOpacity>
				<TouchableOpacity
					onPress={enableBackInteractive}
					activeOpacity={0.2}
					style={styles.button}
				>
					<Text style={styles.buttonText}>enable back interactive</Text>
				</TouchableOpacity>
			</>
		);
	}

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={true}
			contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
		>
			<View style={[styles.container, { paddingTop: insets.top }]}>{component}</View>
		</ScrollView>
	);
}
