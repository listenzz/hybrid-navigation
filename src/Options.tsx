import React, { useState, useEffect } from 'react';
import { View, Image, ScrollView, PixelRatio } from 'react-native';
import Navigation, {
	withNavigationItem,
	NavigationProps,
	ImageSource,
	TabBarStyle,
	TabItemInfo,
	useVisibleEffect,
} from 'hybrid-navigation';

import styles from './Styles';
import TopBar from './TopBar';
import demoTheme from './Theme';
import { DemoActionRow, DemoSection } from './DemoUI';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default withNavigationItem({
	tabItem: {
		title: 'Options',
		icon: Image.resolveAssetSource(require('./images/settings.png')),
	},
})(Options);

const icons = {
	screen: require('./images/action_screen.png'),
	status: require('./images/action_status.png'),
	lock: require('./images/action_lock.png'),
	rotate: require('./images/action_rotate.png'),
	tab: require('./images/action_tab.png'),
	badge: require('./images/action_badge.png'),
	image: require('./images/action_image.png'),
	palette: require('./images/action_palette.png'),
};

function Options({ sceneId, navigator }: NavigationProps) {
	const insets = useSafeAreaInsets();

	useVisibleEffect(() => {
		console.info('Page Options is visible');
		return () => {
			console.info('Page Options is invisible');
		};
	});

	useEffect(() => {
		console.info('Page Options mounted');
		return () => {
			console.info('Page Options unmounted');
		};
	}, []);

	function passOptions() {
		navigator.push('PassOptions');
	}

	function switchTab() {
		navigator.switchTab(0);
	}

	const [badges, setBadges] = useState<Array<TabItemInfo>>();

	function toggleTabBadge() {
		if (badges && badges[0].badge?.dot) {
			setBadges([
				{ index: 0, badge: { hidden: true } },
				{ index: 1, badge: { hidden: true } },
			]);
		} else {
			setBadges([
				{ index: 0, badge: { hidden: false, dot: true } },
				{ index: 1, badge: { hidden: false, text: '99' } },
			]);
		}
	}

	useEffect(() => {
		if (badges) {
			Navigation.setTabItem(sceneId, badges);
		}
	}, [badges, sceneId]);

	function statusBarStyle() {
		navigator.push('TopBarStyle');
	}

	function statusBarHidden() {
		navigator.push('StatusBarHidden');
	}

	function backInteractive() {
		navigator.push('Noninteractive');
	}

	function landscape() {
		navigator.push('Landscape');
	}

	const [icon, setIcon] = useState<ImageSource>();

	function replaceTabIcon() {
		if (icon && icon.uri === 'flower') {
			setIcon(Image.resolveAssetSource(require('./images/settings.png')));
		} else {
			setIcon({ uri: 'flower', scale: PixelRatio.get() });
		}
	}

	useEffect(() => {
		if (icon) {
			Navigation.setTabItem(sceneId, {
				index: 1,
				icon: {
					selected: icon,
				},
			});
		}
	}, [icon, sceneId]);

	const [tabItemColor, setTabItemColor] = useState<TabBarStyle>();

	function replaceTabItemColor() {
		if (tabItemColor && tabItemColor.tabBarItemSelectedColor === demoTheme.colors.accent) {
			setTabItemColor({
				tabBarItemSelectedColor: demoTheme.colors.tabSelected,
				tabBarItemNormalColor: demoTheme.colors.tabUnselected,
			});
		} else {
			setTabItemColor({
				tabBarItemSelectedColor: demoTheme.colors.accent,
				tabBarItemNormalColor: demoTheme.colors.tabUnselected,
			});
		}
	}

	useEffect(() => {
		if (tabItemColor) {
			Navigation.updateTabBar(sceneId, tabItemColor);
		}
	}, [tabItemColor, sceneId]);

	const [tabBarColor, setTabBarColor] = useState<TabBarStyle>();

	function updateTabBarColor() {
		if (tabBarColor && tabBarColor.tabBarBackgroundColor === demoTheme.colors.surfaceSoft) {
			setTabBarColor({
				tabBarBackgroundColor: demoTheme.colors.background,
				tabBarShadowImage: {
					color: demoTheme.colors.border,
				},
			});
		} else {
			setTabBarColor({
				tabBarBackgroundColor: demoTheme.colors.surfaceSoft,
				tabBarShadowImage: {
					color: demoTheme.colors.border,
				},
			});
		}
	}

	useEffect(() => {
		if (tabBarColor) {
			Navigation.updateTabBar(sceneId, tabBarColor);
		}
	}, [tabBarColor, sceneId]);

	return (
		<View style={styles.screen}>
			<TopBar
				title="Options"
				navigator={navigator}
				leftAction={{
					label: 'Menu',
					accessibilityLabel: 'Menu',
					icon: require('./images/menu.png'),
					onPress: () => {
						navigator.toggleMenu();
					},
				}}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
				contentContainerStyle={[
					styles.scrollContent,
					{ paddingBottom: insets.bottom + 24 },
				]}
			>
				<View style={styles.container}>
					<DemoSection title="Screens">
						<DemoActionRow
							icon={icons.screen}
							title="Pass options"
							description="Push a scene that receives navigation options."
							onPress={passOptions}
						/>
						<DemoActionRow
							icon={icons.status}
							title="Status bar style"
							description="Toggle between dark and light status bar content."
							onPress={statusBarStyle}
						/>
						<DemoActionRow
							icon={icons.status}
							title="Status bar hidden"
							description="Open a scene that can hide and show the status bar."
							onPress={statusBarHidden}
						/>
						<DemoActionRow
							icon={icons.lock}
							title="Back interactive"
							description="Test enabling and disabling the back gesture."
							onPress={backInteractive}
						/>
						<DemoActionRow
							icon={icons.rotate}
							title="Landscape"
							description="Open a landscape-only scene."
							onPress={landscape}
						/>
					</DemoSection>

					<DemoSection title="Tab bar">
						<DemoActionRow
							icon={icons.tab}
							title="Switch to Navigation"
							description="Jump back to the Navigation tab."
							onPress={switchTab}
						/>
						<DemoActionRow
							icon={icons.badge}
							title={
								badges && badges[0].badge?.dot ? 'Hide tab badge' : 'Show tab badge'
							}
							description="Toggle a dot badge and a numeric badge."
							onPress={toggleTabBadge}
						/>
						<DemoActionRow
							icon={icons.image}
							title="Replace tab icon"
							description="Switch the Options tab icon source."
							onPress={replaceTabIcon}
						/>
						<DemoActionRow
							icon={icons.palette}
							title="Replace item color"
							description="Toggle selected and unselected tab item colors."
							onPress={replaceTabItemColor}
						/>
						<DemoActionRow
							icon={icons.palette}
							title="Replace bar color"
							description="Toggle the tab bar background treatment."
							onPress={updateTabBarColor}
						/>
					</DemoSection>
				</View>
			</ScrollView>
		</View>
	);
}
