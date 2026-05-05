import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { NavigationProps, useVisibleEffect } from 'hybrid-navigation';

import demoTheme from './Theme';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const conversations = [
	'Drawer reveal interaction',
	'Native stack rotation checks',
	'Safe area status bar polish',
	'Hybrid tab navigation',
	'Deep link route graph',
	'Modal result handoff',
];

const { colors, radius } = demoTheme;

export default function Menu({ navigator }: NavigationProps) {
	const inset = useSafeAreaInsets();

	useVisibleEffect(() => {
		console.log('Menu is visible');
		return () => console.log('Menu is invisible');
	});

	return (
		<View
			style={[
				menuStyles.root,
				{ paddingTop: inset.top + 12, paddingBottom: inset.bottom + 12 },
			]}
		>
			<View style={menuStyles.header}>
				<View style={menuStyles.mark}>
					<Text style={menuStyles.markText}>H</Text>
				</View>
				<View style={menuStyles.headerText}>
					<Text style={menuStyles.title}>Hybrid</Text>
					<Text style={menuStyles.subtitle}>Navigation demo</Text>
				</View>
			</View>

			<TouchableOpacity
				activeOpacity={0.72}
				style={menuStyles.primaryAction}
				onPress={() => navigator.closeMenu()}
				accessibilityRole="button"
				accessibilityLabel="New thread"
			>
				<Text style={menuStyles.primaryActionText}>New thread</Text>
			</TouchableOpacity>

			<ScrollView
				style={menuStyles.list}
				contentContainerStyle={menuStyles.listContent}
				showsVerticalScrollIndicator={false}
			>
				<Text style={menuStyles.sectionTitle}>Today</Text>
				{conversations.map((item, index) => (
					<TouchableOpacity
						key={item}
						activeOpacity={0.68}
						style={[menuStyles.item, index === 0 && menuStyles.itemActive]}
						onPress={() => navigator.closeMenu()}
						accessibilityRole="button"
						accessibilityLabel={item}
					>
						<Text
							style={[menuStyles.itemText, index === 0 && menuStyles.itemTextActive]}
							numberOfLines={1}
						>
							{item}
						</Text>
					</TouchableOpacity>
				))}
			</ScrollView>

			<TouchableOpacity
				activeOpacity={0.72}
				style={menuStyles.footer}
				onPress={() => navigator.closeMenu()}
				accessibilityRole="button"
				accessibilityLabel="Settings"
			>
				<View style={menuStyles.footerAvatar}>
					<Text style={menuStyles.footerAvatarText}>L</Text>
				</View>
				<View style={menuStyles.footerText}>
					<Text style={menuStyles.footerTitle}>Local demo</Text>
					<Text style={menuStyles.footerSubtitle}>Settings</Text>
				</View>
			</TouchableOpacity>
		</View>
	);
}

const menuStyles = StyleSheet.create({
	root: {
		flex: 1,
		backgroundColor: colors.background,
		paddingHorizontal: 14,
	},
	header: {
		minHeight: 52,
		flexDirection: 'row',
		alignItems: 'center',
	},
	mark: {
		width: 34,
		height: 34,
		borderRadius: radius.sm,
		backgroundColor: colors.dark,
		alignItems: 'center',
		justifyContent: 'center',
	},
	markText: {
		color: colors.textOnDark,
		fontSize: 16,
		fontWeight: '700',
	},
	headerText: {
		flex: 1,
		marginLeft: 10,
	},
	title: {
		color: colors.text,
		fontSize: 18,
		fontWeight: '700',
	},
	subtitle: {
		color: colors.textMuted,
		fontSize: 12,
		marginTop: 2,
	},
	primaryAction: {
		height: 42,
		borderRadius: radius.md,
		marginTop: 12,
		paddingHorizontal: 14,
		backgroundColor: colors.surface,
		justifyContent: 'center',
		borderWidth: StyleSheet.hairlineWidth,
		borderColor: colors.border,
	},
	primaryActionText: {
		color: colors.dark,
		fontSize: 15,
		fontWeight: '600',
	},
	list: {
		flex: 1,
		marginTop: 18,
	},
	listContent: {
		paddingBottom: 18,
	},
	sectionTitle: {
		color: colors.textSubtle,
		fontSize: 12,
		fontWeight: '600',
		marginBottom: 8,
		paddingHorizontal: 8,
		textTransform: 'uppercase',
	},
	item: {
		height: 42,
		borderRadius: radius.md,
		paddingHorizontal: 12,
		justifyContent: 'center',
		marginBottom: 4,
	},
	itemActive: {
		backgroundColor: colors.surfaceActive,
	},
	itemText: {
		color: colors.textBody,
		fontSize: 15,
	},
	itemTextActive: {
		color: colors.textStrong,
		fontWeight: '600',
	},
	footer: {
		minHeight: 54,
		borderRadius: radius.lg,
		flexDirection: 'row',
		alignItems: 'center',
		paddingHorizontal: 8,
		backgroundColor: colors.surfaceSoft,
	},
	footerAvatar: {
		width: 34,
		height: 34,
		borderRadius: 17,
		backgroundColor: colors.accent,
		alignItems: 'center',
		justifyContent: 'center',
	},
	footerAvatarText: {
		color: colors.surface,
		fontSize: 14,
		fontWeight: '700',
	},
	footerText: {
		flex: 1,
		marginLeft: 10,
	},
	footerTitle: {
		color: colors.dark,
		fontSize: 14,
		fontWeight: '600',
	},
	footerSubtitle: {
		color: colors.textMuted,
		fontSize: 12,
		marginTop: 2,
	},
});
