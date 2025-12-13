import React, { useState, useEffect } from 'react';
import { Text, View, ScrollView, Switch } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';

export default withNavigationItem({
	topBarShadowHidden: true,
	titleItem: {
		title: 'Hide Shadow',
	},
})(TopBarShadowHidden);

function TopBarShadowHidden({ sceneId }: NavigationProps) {
	const [hidden, setHidden] = useState(true);

	useEffect(() => {
		Navigation.updateOptions(sceneId, { topBarShadowHidden: hidden });
	}, [hidden, sceneId]);

	function handleHiddenChange(value: boolean) {
		setHidden(value);
	}

	return (
		<ScrollView>
			<View style={styles.container}>
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
