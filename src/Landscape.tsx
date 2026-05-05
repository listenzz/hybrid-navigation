import React, { useEffect } from 'react';
import { View, ScrollView } from 'react-native';
import { useNavigator, useVisibleEffect, withNavigationItem } from 'hybrid-navigation';
import styles from './Styles';
import { DemoActionRow, DemoSection } from './DemoUI';

export default withNavigationItem({
	statusBarHidden: true,
	backInteractive: false,
	forceScreenLandscape: true,
	homeIndicatorAutoHiddenIOS: true,
})(Landscape);

const icons = {
	back: require('./images/action_back.png'),
	modal: require('./images/action_modal.png'),
};

function Landscape() {
	useEffect(() => {
		console.info(`Page Landscape mounted`);
		return () => {
			console.info(`Page Landscape unmounted`);
		};
	}, []);

	useVisibleEffect(() => {
		console.info(`Page Landscape is visible`);
		return () => console.info(`Page Landscape is invisible`);
	});

	const navigator = useNavigator();

	const back = () => {
		navigator.pop();
	};

	const showModal = () => {
		navigator.showModal('ReactModal');
	};

	return (
		<View style={styles.screen}>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<DemoSection title="Landscape">
						<DemoActionRow
							icon={icons.back}
							title="Back"
							description="Return to the previous portrait scene."
							onPress={back}
						/>
						<DemoActionRow
							icon={icons.modal}
							title="Show modal"
							description="Open the React bottom modal from landscape."
							onPress={showModal}
						/>
					</DemoSection>
				</View>
			</ScrollView>
		</View>
	);
}
