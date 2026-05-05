import React, { useState } from 'react';
import { View, ScrollView } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import styles from './Styles';
import TopBar from './TopBar';
import { DemoActionRow, DemoSection } from './DemoUI';

export default withNavigationItem({
	backInteractive: false,
})(Noninteractive);

const icons = {
	back: require('./images/action_back.png'),
	lock: require('./images/action_lock.png'),
	unlock: require('./images/action_unlock.png'),
};

function Noninteractive({ navigator, sceneId }: NavigationProps) {
	const [backInteractive, setBackInteractive] = useState(false);

	function handleBackClick() {
		navigator.pop();
	}

	function enableBackInteractive() {
		Navigation.updateOptions(sceneId, {
			backInteractive: true,
		});
		setBackInteractive(true);
	}

	function disableBackInteractive() {
		Navigation.updateOptions(sceneId, {
			backInteractive: false,
		});
		setBackInteractive(false);
	}

	return (
		<View style={styles.screen}>
			<TopBar
				title="Noninteractive"
				navigator={navigator}
				showBackWhenPossible={backInteractive}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<DemoSection title="Back gesture">
						<DemoActionRow
							icon={backInteractive ? icons.unlock : icons.lock}
							title={backInteractive ? 'Disable back gesture' : 'Enable back gesture'}
							description={
								backInteractive
									? 'Gesture navigation is enabled for this scene.'
									: 'Gesture navigation is locked for this scene.'
							}
							onPress={
								backInteractive ? disableBackInteractive : enableBackInteractive
							}
						/>
						{backInteractive ? null : (
							<DemoActionRow
								icon={icons.back}
								title="Back"
								description="Pop this scene using the explicit action."
								onPress={handleBackClick}
							/>
						)}
					</DemoSection>
				</View>
			</ScrollView>
		</View>
	);
}
