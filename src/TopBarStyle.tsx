import React, { useState, useEffect } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import Navigation, {
	BarStyleLightContent,
	BarStyleDarkContent,
	NavigationOption,
	withNavigationItem,
	NavigationProps,
} from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default withNavigationItem({
	statusBarStyle: BarStyleLightContent,
})(TopBarStyle);

function TopBarStyle({ navigator, sceneId }: NavigationProps) {
	const [options, setOptions] = useState<NavigationOption>();

	useEffect(() => {
		if (options) {
			Navigation.updateOptions(sceneId, options);
		}
	}, [options, sceneId]);

	function switchStatusBarStyle() {
		if (options && options.statusBarStyle === BarStyleDarkContent) {
			setOptions({
				statusBarStyle: BarStyleLightContent,
				screenBackgroundColor: '#F8F8F8',
			});
		} else {
			setOptions({
				statusBarStyle: BarStyleDarkContent,
				screenBackgroundColor: '#F0F0F0',
			});
		}
	}

	function topBarStyle() {
		navigator.push('TopBarStyle');
	}

	async function showModal() {
		await navigator.showModal('ReactModal');
	}

	const darkContent = options?.statusBarStyle === BarStyleDarkContent;

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar
				title="StatusBar Style"
				navigator={navigator}
				backgroundColor={darkContent ? '#FFFFFF' : '#1F2D4A'}
				titleColor={darkContent ? '#111111' : '#FFFFFF'}
				tintColor={darkContent ? '#1F4FCC' : '#FFFFFF'}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.text}>
						1. Status bar text can only be white on Android below 6.0
					</Text>

					<Text style={styles.text}>2. Toggle `statusBarStyle` to test dark/light content.</Text>

					<TouchableOpacity onPress={switchStatusBarStyle} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>
							switch to {darkContent ? 'Light Content Style' : 'Dark Content Style'}
						</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarStyle} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>push TopBarStyle</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>show react modal</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
