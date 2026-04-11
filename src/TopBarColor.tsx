import React, { useState } from 'react';
import { Text, View, TouchableOpacity, ScrollView } from 'react-native';
import { NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default function TopBarColor({ navigator }: NavigationProps) {
	const [topBarColor, setTopBarColor] = useState('#FF0000');

	function topBarColorPage() {
		navigator.push('TopBarColor');
	}

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar title="TopBar Color" navigator={navigator} backgroundColor={topBarColor} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>Bright colors</Text>

					<TouchableOpacity
						onPress={() => setTopBarColor('#FF0000')}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>Red</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={() => setTopBarColor('#0000FF')}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>Blue</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={() => setTopBarColor('#00AA55')}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>Green</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={topBarColorPage} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>push TopBarColor</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
