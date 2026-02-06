import React, { useEffect } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import { useNavigator, useVisibleEffect } from 'hybrid-navigation';
import styles from './Styles';
import { withNavigationItem } from 'hybrid-navigation';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default withNavigationItem({
	topBarHidden: true,
	statusBarHidden: true,
	backInteractive: false,
	forceScreenLandscape: true,
	animatedTransition: false,
	homeIndicatorAutoHiddenIOS: true,
	titleItem: {
		title: 'Landscape',
	},
})(Landscape);

function Landscape() {
	useEffect(() => {
		console.info(`Page Landscape mounted`);
		return () => {
			console.info(`Page Landscape unmounted`);
		};
	}, []);

	useVisibleEffect(() => {
		console.info(`Page Landscape is visible`);
		return () => console.info(`Page Landscape is invisible`);
	});

	const navigator = useNavigator();
	const insets = useSafeAreaInsets();

	const back = () => {
		navigator.pop();
	};

	const showModal = () => {
		navigator.showModal('ReactModal');
	};

	function topBarMisc() {
		navigator.push('TopBarMisc');
	}

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={false}
			contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
		>
			<View style={[styles.container, { paddingTop: insets.top }]}>
				<TouchableOpacity onPress={back} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>Back</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>showModal</Text>
				</TouchableOpacity>
				<TouchableOpacity onPress={topBarMisc} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>topBar options</Text>
				</TouchableOpacity>
			</View>
		</ScrollView>
	);
}
