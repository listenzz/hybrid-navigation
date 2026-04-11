import React from 'react';
import { Text, View, TouchableOpacity, ScrollView, Alert } from 'react-native';
import { NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

function CustomTitleView({ onPress }: { onPress: () => void }) {
	return (
		<View
			style={{
				flexDirection: 'row',
				justifyContent: 'center',
				alignItems: 'center',
			}}
		>
			<Text style={{ fontSize: 17, fontWeight: 'bold', marginRight: 12 }}>--Custom Title--</Text>
			<TouchableOpacity onPress={onPress}>
				<Text style={{ color: '#1F4FCC', fontSize: 16 }}>Click</Text>
			</TouchableOpacity>
		</View>
	);
}

export default function TopBarTitleView({ navigator }: NavigationProps) {
	function onTitleActionPress() {
		Alert.alert('Hello!', 'React title action is clicked.', [{ text: 'OK' }], {
			cancelable: false,
		});
	}

	function topBarTitleView() {
		navigator.push('TopBarTitleView');
	}

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar
				title=""
				navigator={navigator}
				titleNode={<CustomTitleView onPress={onTitleActionPress} />}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>Custom title bar</Text>

					<TouchableOpacity onPress={topBarTitleView} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>push TopBarTitleView</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
