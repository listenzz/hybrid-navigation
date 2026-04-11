import React, { useState, useEffect } from 'react';
import { TouchableOpacity, Text, View, Image, ScrollView, PixelRatio } from 'react-native';
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

export default withNavigationItem({
	tabItem: {
		title: 'Options',
		icon: Image.resolveAssetSource(require('./images/flower_1.png')),
	},
})(Options);

function Options({ sceneId, navigator }: NavigationProps) {
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
			setIcon(Image.resolveAssetSource(require('./images/flower_1.png')));
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
		if (tabItemColor && tabItemColor.tabBarItemSelectedColor === '#8BC34A') {
			setTabItemColor({
				tabBarItemSelectedColor: '#FF5722',
				tabBarItemNormalColor: '#666666',
			});
		} else {
			setTabItemColor({
				tabBarItemSelectedColor: '#8BC34A',
				tabBarItemNormalColor: '#666666',
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
		if (tabBarColor && tabBarColor.tabBarBackgroundColor === '#EEEEEE') {
			setTabBarColor({
				tabBarBackgroundColor: '#FFFFFF',
				tabBarShadowImage: {
					color: '#F0F0F0',
				},
			});
		} else {
			setTabBarColor({
				tabBarBackgroundColor: '#EEEEEE',
				tabBarShadowImage: {
					image: Image.resolveAssetSource(require('./images/divider.png')),
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
		<View style={{ flex: 1 }}>
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
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>This's a React Native scene.</Text>

					<TouchableOpacity onPress={passOptions} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>pass options to another scene</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={statusBarStyle} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>StatusBar Style</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={statusBarHidden}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>StatusBar Hidden</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={backInteractive} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Back Interactive</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={landscape} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>Landscape</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={switchTab} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>switch to tab 'Navigation'</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={toggleTabBadge}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>
							{badges && badges[0].badge?.dot ? 'hide tab badge' : 'show tab badge'}
						</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={replaceTabIcon}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>replace tab icon</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={replaceTabItemColor}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>replace tab item color</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={updateTabBarColor}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>replace tab bar color</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		</View>
	);
}
