import React, { useState, useEffect } from 'react';
import { View, ScrollView } from 'react-native';
import Navigation, {
	BarStyleLightContent,
	BarStyleDarkContent,
	NavigationOption,
	withNavigationItem,
	NavigationProps,
} from 'hybrid-navigation';
import styles from './Styles';
import TopBar from './TopBar';
import demoTheme from './Theme';
import { DemoActionRow, DemoNote, DemoSection } from './DemoUI';

export default withNavigationItem({
	statusBarStyle: BarStyleLightContent,
})(TopBarStyle);

const icons = {
	status: require('./images/action_status.png'),
	push: require('./images/action_push.png'),
	modal: require('./images/action_modal.png'),
};

function TopBarStyle({ navigator, sceneId }: NavigationProps) {
	const [options, setOptions] = useState<NavigationOption>();

	useEffect(() => {
		if (options) {
			Navigation.updateOptions(sceneId, options);
		}
	}, [options, sceneId]);

	function switchStatusBarStyle() {
		if (options && options.statusBarStyle === BarStyleDarkContent) {
			setOptions({
				statusBarStyle: BarStyleLightContent,
				screenBackgroundColor: demoTheme.colors.background,
			});
		} else {
			setOptions({
				statusBarStyle: BarStyleDarkContent,
				screenBackgroundColor: demoTheme.colors.surfaceSoft,
			});
		}
	}

	function topBarStyle() {
		navigator.push('TopBarStyle');
	}

	async function showModal() {
		await navigator.showModal('ReactModal');
	}

	const darkContent = options?.statusBarStyle === BarStyleDarkContent;

	return (
		<View style={styles.screen}>
			<TopBar
				title="StatusBar Style"
				navigator={navigator}
				backgroundColor={darkContent ? demoTheme.colors.background : demoTheme.colors.dark}
				titleColor={darkContent ? demoTheme.colors.text : demoTheme.colors.textOnDark}
				tintColor={darkContent ? demoTheme.colors.accent : demoTheme.colors.textOnDark}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<DemoSection title="Status bar">
						<DemoNote
							title="Android compatibility"
							body="Status bar text can only be white on Android below 6.0."
						/>
						<DemoActionRow
							icon={icons.status}
							title={`Switch to ${darkContent ? 'light content' : 'dark content'}`}
							description="Toggle statusBarStyle and the matching top bar colors."
							onPress={switchStatusBarStyle}
						/>
						<DemoActionRow
							icon={icons.push}
							title="Push TopBarStyle"
							description="Open another copy of this style demo."
							onPress={topBarStyle}
						/>
						<DemoActionRow
							icon={icons.modal}
							title="Show react modal"
							description="Open the custom React bottom modal."
							onPress={showModal}
						/>
					</DemoSection>
				</View>
			</ScrollView>
		</View>
	);
}
