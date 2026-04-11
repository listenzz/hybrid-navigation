import React, { useEffect, useMemo, useState } from 'react';
import { TouchableOpacity, Text, View, StyleSheet } from 'react-native';
import type { Navigator } from 'hybrid-navigation';
import { initialWindowMetrics, useSafeAreaInsets } from 'react-native-safe-area-context';

type Action = {
	label: string;
	onPress: () => void;
	disabled?: boolean;
};

interface Props {
	title: string;
	navigator: Navigator;
	titleNode?: React.ReactNode;
	leftAction?: Action;
	rightAction?: Action;
	showBackWhenPossible?: boolean;
	backgroundColor?: string;
	alpha?: number;
	shadowHidden?: boolean;
	tintColor?: string;
	titleColor?: string;
}

const SIDE_WIDTH = 88;
let cachedTopInset = initialWindowMetrics?.insets.top ?? 0;

export default function RNTopBar({
	title,
	navigator,
	titleNode,
	leftAction,
	rightAction,
	showBackWhenPossible = true,
	backgroundColor = '#FFFFFF',
	alpha = 1,
	shadowHidden = false,
	tintColor = '#1F4FCC',
	titleColor = '#111111',
}: Props) {
	const insets = useSafeAreaInsets();
	const [isRoot, setIsRoot] = useState(false);
	const [stableTopInset, setStableTopInset] = useState(() => Math.max(insets.top, cachedTopInset));

	useEffect(() => {
		// Keep a stable top inset so toggling status bar visibility
		// does not change TopBar height.
		const nextTopInset = Math.max(insets.top, cachedTopInset);
		if (nextTopInset > cachedTopInset) {
			cachedTopInset = nextTopInset;
		}
		if (nextTopInset !== stableTopInset) {
			setStableTopInset(nextTopInset);
		}
	}, [insets.top, stableTopInset]);

	useEffect(() => {
		let mounted = true;
		navigator.isStackRoot().then(root => {
			if (mounted) {
				setIsRoot(root);
			}
		});
		return () => {
			mounted = false;
		};
	}, [navigator]);

	const resolvedLeftAction = useMemo<Action | undefined>(() => {
		if (showBackWhenPossible && !isRoot) {
			return {
				label: 'Back',
				onPress: () => {
					navigator.pop();
				},
			};
		}
		return leftAction;
	}, [isRoot, leftAction, navigator, showBackWhenPossible]);

	return (
		<View
			style={[
				styles.wrapper,
				{ paddingTop: stableTopInset, backgroundColor, opacity: alpha },
			]}
		>
			<View style={styles.row}>
				<Side action={resolvedLeftAction} tintColor={tintColor} />
				<View style={styles.titleContainer}>
					{titleNode ? (
						titleNode
					) : (
						<Text style={[styles.title, { color: titleColor }]} numberOfLines={1}>
							{title}
						</Text>
					)}
				</View>
				<Side action={rightAction} tintColor={tintColor} alignRight />
			</View>
			{shadowHidden ? null : <View style={styles.shadow} />}
		</View>
	);
}

function Side({
	action,
	tintColor,
	alignRight,
}: {
	action?: Action;
	tintColor: string;
	alignRight?: boolean;
}) {
	if (!action) {
		return <View style={[styles.side, alignRight && styles.sideRight]} />;
	}

	return (
		<TouchableOpacity
			disabled={action.disabled}
			onPress={action.onPress}
			activeOpacity={0.7}
			style={[styles.side, alignRight && styles.sideRight]}
		>
			<Text style={[styles.actionText, { color: action.disabled ? '#BDBDBD' : tintColor }]}>
				{action.label}
			</Text>
		</TouchableOpacity>
	);
}

const styles = StyleSheet.create({
	wrapper: {
		zIndex: 2,
	},
	row: {
		height: 44,
		flexDirection: 'row',
		alignItems: 'center',
	},
	title: {
		fontSize: 17,
		fontWeight: '600',
		textAlign: 'center',
	},
	titleContainer: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
	},
	side: {
		width: SIDE_WIDTH,
		height: 44,
		justifyContent: 'center',
		paddingHorizontal: 12,
	},
	sideRight: {
		alignItems: 'flex-end',
	},
	actionText: {
		fontSize: 16,
	},
	shadow: {
		height: StyleSheet.hairlineWidth,
		backgroundColor: '#DDDDDD',
	},
});
