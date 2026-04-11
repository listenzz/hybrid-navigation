import React, { useState } from 'react';
import { Text, View, TouchableOpacity, ScrollView } from 'react-native';
import Slider from '@react-native-community/slider';
import styles from './Styles';
import { NavigationProps } from 'hybrid-navigation';
import RNTopBar from './RNTopBar';

interface Props extends NavigationProps {
	alpha: number;
}

export default function TopBarAlpha({ navigator, alpha }: Props) {
	const [topBarAlpha, setTopBarAlpha] = useState(alpha ? Number(alpha) : 0.5);

	function pushToTopBarAlpha() {
		navigator.push('TopBarAlpha');
	}

	function handleAlphaChange(value: number) {
		setTopBarAlpha(Number(value.toFixed(2)));
	}

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar title="TopBar Alpha" navigator={navigator} alpha={topBarAlpha} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>Try to slide</Text>
					<Slider
						style={{ marginLeft: 32, marginRight: 32, marginTop: 40 }}
						onValueChange={handleAlphaChange}
						step={0.01}
						value={topBarAlpha}
					/>

					<Text style={styles.result}>alpha: {topBarAlpha}</Text>

					<TouchableOpacity onPress={pushToTopBarAlpha} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>push TopBarAlpha</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
