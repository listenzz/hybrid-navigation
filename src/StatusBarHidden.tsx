import React from 'react';
import { View, ScrollView } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';
import { SafeAreaView } from 'react-native-safe-area-context';
import styles from './Styles';
import { DemoActionRow, DemoSection } from './DemoUI';

export default withNavigationItem({
	statusBarHidden: true,
})(StatusBarHidden);

const icons = {
	status: require('./images/action_status.png'),
	push: require('./images/action_push.png'),
};

function StatusBarHidden({ navigator, sceneId }: NavigationProps) {
	function statusBarHiddenPage() {
		navigator.push('StatusBarHidden');
	}

	function showStatusBar() {
		Navigation.updateOptions(sceneId, { statusBarHidden: false });
	}

	function hideStatusBar() {
		Navigation.updateOptions(sceneId, { statusBarHidden: true });
	}

	return (
		<SafeAreaView style={styles.screen} edges={['top', 'bottom']}>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<DemoSection title="Status bar">
						<DemoActionRow
							icon={icons.status}
							title="Show status bar"
							description="Update this scene to reveal the status bar."
							onPress={showStatusBar}
						/>
						<DemoActionRow
							icon={icons.status}
							title="Hide status bar"
							description="Update this scene to hide the status bar again."
							onPress={hideStatusBar}
						/>
						<DemoActionRow
							icon={icons.push}
							title="Push hidden scene"
							description="Open another StatusBarHidden scene."
							onPress={statusBarHiddenPage}
						/>
					</DemoSection>
				</View>
			</ScrollView>
		</SafeAreaView>
	);
}
