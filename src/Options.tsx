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
import RNTopBar from './RNTopBar';

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

	const [showsLeftAction, setShowsLeftAction] = useState(true);
	const [rightActionEnabled, setRightActionEnabled] = useState(false);
	const [title, setTitle] = useState('Options');

	function toggleLeftAction() {
		setShowsLeftAction(!showsLeftAction);
	}

	function changeRightAction() {
		setRightActionEnabled(!rightActionEnabled);
	}

	function changeTitle() {
		setTitle(title === 'Options' ? '配置' : 'Options');
	}

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

	function topBarMisc() {
		navigator.push('TopBarMisc');
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
			<RNTopBar
				title={title}
				navigator={navigator}
				leftAction={
					showsLeftAction
						? {
								label: 'Menu',
								accessibilityLabel: 'Menu',
								icon: require('./images/menu.png'),
								onPress: () => {
									navigator.toggleMenu();
								},
							}
						: undefined
				}
				rightAction={{
					label: 'TopBar demos',
					accessibilityLabel: 'TopBar demos',
					icon: require('./images/settings.png'),
					onPress: topBarMisc,
					disabled: !rightActionEnabled,
				}}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			>
				<View style={styles.container}>
					<Text style={styles.welcome}>This's a React Native scene.</Text>

					<TouchableOpacity onPress={topBarMisc} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>topBar demos</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={passOptions} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>pass options to another scene</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={toggleLeftAction}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>
							{showsLeftAction ? 'hide left action' : 'show left action'}
						</Text>
					</TouchableOpacity>

					<TouchableOpacity
						onPress={changeRightAction}
						activeOpacity={0.2}
						style={styles.button}
					>
						<Text style={styles.buttonText}>
							{rightActionEnabled ? 'disable right action' : 'enable right action'}
						</Text>
					</TouchableOpacity>

					<TouchableOpacity onPress={changeTitle} activeOpacity={0.2} style={styles.button}>
						<Text style={styles.buttonText}>{`change title to '${
							title === 'Options' ? '配置' : 'Options'
						}'`}</Text>
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
