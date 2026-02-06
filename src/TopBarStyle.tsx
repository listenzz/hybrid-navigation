import React, { useState, useEffect } from 'react';
import { TouchableOpacity, Text, View, ScrollView, Image } from 'react-native';
import Navigation, {
	BarStyleLightContent,
	BarStyleDarkContent,
	useNavigator,
	NavigationOption,
} from 'hybrid-navigation';
import styles from './Styles';
import { withNavigationItem } from 'hybrid-navigation';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default withNavigationItem({
	topBarStyle: BarStyleLightContent,

	titleItem: {
		title: 'TopBar Style',
	},

	rightBarButtonItem: {
		icon: Image.resolveAssetSource(require('./images/settings.png')),
		action: navigator => {
			navigator.push('TopBarMisc');
		},
	},
})(TopBarStyle);

function TopBarStyle() {
	const [options, setOptions] = useState<NavigationOption>();
	const navigator = useNavigator();
	const insets = useSafeAreaInsets();

	useEffect(() => {
		if (options) {
			Navigation.updateOptions(navigator.sceneId, options);
		}
	}, [options, navigator]);

	function switchTopBarStyle() {
		if (options && options.topBarStyle === BarStyleDarkContent) {
			setOptions({
				topBarStyle: BarStyleLightContent,
				screenBackgroundColor: '#F8F8F8',
			});
		} else {
			setOptions({
				topBarStyle: BarStyleDarkContent,
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

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={true}
			contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
		>
			<View style={[styles.container, { paddingTop: insets.top }]}>
				<Text style={styles.text}>
					1. Status bar text can only be white on Android below 6.0
				</Text>

				<Text style={styles.text}>
					2. Status bar color may be adjusted if topBarStyle is dark-content on Android
					below 6.0
				</Text>

				<TouchableOpacity
					onPress={switchTopBarStyle}
					activeOpacity={0.2}
					style={styles.button}
				>
					<Text style={styles.buttonText}>
						switch to{' '}
						{options && options.topBarStyle === BarStyleDarkContent
							? 'Light Content Style'
							: 'Dark Content Style'}
					</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={topBarStyle} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>TopBarStyle</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>show react modal</Text>
				</TouchableOpacity>
			</View>
		</ScrollView>
	);
}
