import React, { useEffect } from 'react';
import { Text, View, TouchableOpacity, ScrollView } from 'react-native';
import { NavigationProps, useVisibleEffect } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default function TopBarMisc({ navigator }: NavigationProps) {
	useEffect(() => {
		console.info(`Page TopBarMisc mounted`);
		return () => {
			console.info(`Page TopBarMisc unmounted`);
		};
	}, []);

	useVisibleEffect(() => {
		console.info(`Page TopBarMisc is visible`);
		return () => console.info(`Page TopBarMisc is invisible`);
	});

	function topBarShadowHidden() {
		navigator.push('TopBarShadowHidden');
	}

	function topBarHidden() {
		navigator.push('TopBarHidden');
	}

	function topBarColor() {
		navigator.push('TopBarColor');
	}

	function topBarAlpha() {
		navigator.push('TopBarAlpha');
	}

	function topBarTitleView() {
		navigator.push('TopBarTitleView');
	}

	function statusBarHidden() {
		navigator.push('StatusBarHidden');
	}

	function topBarStyle() {
		navigator.push('TopBarStyle');
	}

	function noninteractive() {
		navigator.push('Noninteractive');
	}

	function landscape() {
		navigator.push('Landscape');
	}

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar title="RN TopBar Demos" navigator={navigator} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>About RN TopBar</Text>
					<TouchableOpacity onPress={topBarShadowHidden} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Shadow Toggle</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Show / Hide</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarColor} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Color</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarAlpha} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Alpha</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarTitleView} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Custom Title View</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={statusBarHidden} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>StatusBar Hidden</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarStyle} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>StatusBar Style</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={noninteractive} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Back Interactive</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={landscape} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Landscape</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
