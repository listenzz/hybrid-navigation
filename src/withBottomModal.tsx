import React, { useEffect, useCallback, useRef, ComponentType } from 'react';
import {
	StyleSheet,
	Animated,
	Easing,
	Dimensions,
	View,
	TouchableWithoutFeedback,
} from 'react-native';
import { useLayout, useBackHandler } from '@react-native-community/hooks';
import { NavigationProps } from 'hybrid-navigation';
import { SafeAreaView } from 'react-native-safe-area-context';
import demoTheme from './Theme';

export default function withBottomModal({
	cancelable = true,
	backdropColor = 'rgba(31, 29, 26, 0.46)',
	safeAreaColor = demoTheme.colors.background,
	navigationBarColor = demoTheme.colors.background,
} = {}) {
	return function (WrappedComponent: ComponentType<any>) {
		function BottomModal(props: NavigationProps, ref: React.Ref<ComponentType<any>>) {
			const animationProgress = useRef(new Animated.Value(0));
			const hideModalPromise = useRef<Promise<boolean> | null>(null);
			const { onLayout, height } = useLayout();

			const realHideModal = useRef(props.navigator.hideModal);

			const hideModal = useCallback(() => {
				if (hideModalPromise.current) {
					return hideModalPromise.current;
				}

				hideModalPromise.current = new Promise<boolean>(resolve => {
					Animated.timing(animationProgress.current, {
						toValue: 0,
						duration: 220,
						easing: Easing.in(Easing.cubic),
						useNativeDriver: true,
					}).start(({ finished }) => {
						if (finished) {
							resolve(realHideModal.current());
						} else {
							hideModalPromise.current = null;
							resolve(false);
						}
					});
				});

				return hideModalPromise.current;
			}, []);

			props.navigator.hideModal = hideModal;

			useEffect(() => {
				if (height !== 0) {
					Animated.timing(animationProgress.current, {
						toValue: 1,
						duration: 260,
						easing: Easing.out(Easing.cubic),
						useNativeDriver: true,
					}).start();
				}
			}, [height]);

			const handleHardwareBackPress = useCallback(() => {
				cancelable && hideModal();
				return true;
			}, [hideModal]);

			useBackHandler(handleHardwareBackPress);

			const translateY = animationProgress.current.interpolate({
				inputRange: [0, 1],
				outputRange: [height || Dimensions.get('screen').height, 0],
			});

			return (
				<View style={styles.container}>
					<TouchableWithoutFeedback onPress={handleHardwareBackPress}>
						<Animated.View
							style={[
								styles.backdrop,
								{
									backgroundColor: backdropColor,
									opacity: animationProgress.current,
								},
							]}
						/>
					</TouchableWithoutFeedback>

					<Animated.View
						onLayout={onLayout}
						style={[styles.sheet, { transform: [{ translateY }] }]}
					>
						<WrappedComponent {...props} ref={ref} />
						<SafeAreaView
							edges={['bottom']}
							style={{ backgroundColor: safeAreaColor }}
						/>
					</Animated.View>
				</View>
			);
		}

		const FC = React.forwardRef(BottomModal);
		const name = WrappedComponent.displayName || WrappedComponent.name;
		FC.displayName = `withBottomModal(${name})`;

		const navigationItem = (WrappedComponent as any).navigationItem || {};
		if (!navigationItem.navigationBarColorAndroid) {
			navigationItem.navigationBarColorAndroid = navigationBarColor;
		}
		(FC as any).navigationItem = navigationItem;

		return FC;
	};
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		justifyContent: 'flex-end',
	},
	backdrop: {
		position: 'absolute',
		top: 0,
		right: 0,
		bottom: 0,
		left: 0,
	},
	sheet: {
		width: '100%',
	},
});
