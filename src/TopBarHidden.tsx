import React, { useState } from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import { NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default function TopBarHidden({ navigator }: NavigationProps) {
	const [visible, setVisible] = useState(true);

	function topBarHidden() {
		navigator.push('TopBarHidden');
	}

	return (
		<View style={{ flex: 1 }}>
			{visible ? <RNTopBar title="RN TopBar" navigator={navigator} /> : null}
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>{visible ? 'TopBar is visible' : 'TopBar is hidden'}</Text>
					<TouchableOpacity
						onPress={() => {
							setVisible(!visible);
						}}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>{visible ? 'hide top bar' : 'show top bar'}</Text>
					</TouchableOpacity>
					<TouchableOpacity onPress={topBarHidden} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>push TopBarHidden</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
