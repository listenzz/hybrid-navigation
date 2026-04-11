import React, { useEffect } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import { useNavigator, useVisibleEffect, withNavigationItem } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default withNavigationItem({
	statusBarHidden: true,
	backInteractive: false,
	forceScreenLandscape: true,
	homeIndicatorAutoHiddenIOS: true,
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
		<View style={{ flex: 1 }}>
			<RNTopBar title="Landscape" navigator={navigator} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<TouchableOpacity onPress={back} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Back</Text>
					</TouchableOpacity>
					<TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>showModal</Text>
					</TouchableOpacity>
					<TouchableOpacity onPress={topBarMisc} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>topBar demos</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
