import React, { useState } from 'react';
import { Text, View, ScrollView, Switch } from 'react-native';
import { NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import RNTopBar from './RNTopBar';

export default function TopBarShadowHidden({ navigator }: NavigationProps) {
	const [hidden, setHidden] = useState(true);

	function handleHiddenChange(value: boolean) {
		setHidden(value);
	}

	return (
		<View style={{ flex: 1 }}>
			<RNTopBar title="TopBar Shadow" navigator={navigator} shadowHidden={hidden} />
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>
						{hidden ? 'topBar shadow is hidden' : 'topBar shadow is visible'}
					</Text>
					<View style={styles.button}>
						<Switch style={{ alignSelf: 'center' }} onValueChange={handleHiddenChange} value={hidden} />
					</View>
				</View>
			</ScrollView>
		</View>
	);
}
