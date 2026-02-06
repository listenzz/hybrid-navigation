import React, { useState, useEffect } from 'react';
import { Text, View, ScrollView, Switch } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default withNavigationItem({
	topBarShadowHidden: true,
	titleItem: {
		title: 'Hide Shadow',
	},
})(TopBarShadowHidden);

function TopBarShadowHidden({ sceneId }: NavigationProps) {
	const [hidden, setHidden] = useState(true);
	const insets = useSafeAreaInsets();

	useEffect(() => {
		Navigation.updateOptions(sceneId, { topBarShadowHidden: hidden });
	}, [hidden, sceneId]);

	function handleHiddenChange(value: boolean) {
		setHidden(value);
	}

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={true}
			contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
		>
			<View style={[styles.container, { paddingTop: insets.top }]}>
				<Text style={styles.welcome}>
					{hidden ? 'topBar shadow is hidden' : 'topBar shadow is visible'}
				</Text>
				<View style={styles.button}>
					<Switch
						style={{ alignSelf: 'center' }}
						onValueChange={handleHiddenChange}
						value={hidden}
					/>
				</View>
			</View>
		</ScrollView>
	);
}
