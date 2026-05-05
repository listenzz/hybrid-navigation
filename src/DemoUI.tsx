import React from 'react';
import {
	Image,
	ImageSourcePropType,
	StyleSheet,
	Text,
	TouchableHighlight,
	View,
} from 'react-native';

import demoTheme from './Theme';

const { colors, radius } = demoTheme;

interface DemoSectionProps {
	title: string;
	children: React.ReactNode;
}

interface DemoActionRowProps {
	title: string;
	description?: string;
	icon: ImageSourcePropType;
	onPress: () => void;
	disabled?: boolean;
	tintColor?: string;
}

interface DemoNoteProps {
	title: string;
	body?: string;
}

export function DemoSection({ title, children }: DemoSectionProps) {
	return (
		<View style={styles.section}>
			<Text style={styles.sectionTitle}>{title}</Text>
			<View style={styles.rows}>{children}</View>
		</View>
	);
}

export function DemoActionRow({
	title,
	description,
	icon,
	onPress,
	disabled,
	tintColor,
}: DemoActionRowProps) {
	const resolvedTint = disabled ? colors.iconMuted : tintColor ?? colors.primary;

	return (
		<TouchableHighlight
			onPress={onPress}
			disabled={disabled}
			underlayColor={colors.rowPressed}
			style={[styles.row, disabled && styles.rowDisabled]}
			accessibilityRole="button"
			accessibilityLabel={title}
		>
			<View style={styles.rowContent}>
				<View style={[styles.iconShell, disabled && styles.iconShellDisabled]}>
					<Image source={icon} style={[styles.icon, { tintColor: resolvedTint }]} />
				</View>
				<View style={styles.textBlock}>
					<Text
						style={[styles.rowTitle, disabled && styles.rowTitleDisabled]}
						numberOfLines={1}
					>
						{title}
					</Text>
					{description ? (
						<Text style={styles.rowDescription} numberOfLines={2}>
							{description}
						</Text>
					) : null}
				</View>
			</View>
		</TouchableHighlight>
	);
}

export function DemoNote({ title, body }: DemoNoteProps) {
	return (
		<View style={styles.note}>
			<Text style={styles.rowTitle}>{title}</Text>
			{body ? <Text style={styles.rowDescription}>{body}</Text> : null}
		</View>
	);
}

const styles = StyleSheet.create({
	section: {
		marginBottom: 22,
	},
	sectionTitle: {
		color: colors.textSubtle,
		fontSize: 12,
		fontWeight: '700',
		marginBottom: 8,
		paddingHorizontal: 6,
		textTransform: 'uppercase',
	},
	rows: {
		borderWidth: StyleSheet.hairlineWidth,
		borderColor: colors.border,
		borderRadius: radius.lg,
		backgroundColor: colors.surface,
		overflow: 'hidden',
	},
	row: {
		backgroundColor: colors.surface,
		borderBottomWidth: StyleSheet.hairlineWidth,
		borderBottomColor: colors.border,
	},
	rowDisabled: {
		opacity: 0.58,
	},
	rowContent: {
		minHeight: 58,
		flexDirection: 'row',
		alignItems: 'center',
		paddingHorizontal: 12,
		paddingVertical: 9,
	},
	note: {
		paddingHorizontal: 14,
		paddingVertical: 12,
		backgroundColor: colors.surface,
		borderBottomWidth: StyleSheet.hairlineWidth,
		borderBottomColor: colors.border,
	},
	iconShell: {
		width: 34,
		height: 34,
		borderRadius: radius.sm,
		backgroundColor: colors.primaryMuted,
		alignItems: 'center',
		justifyContent: 'center',
		marginRight: 12,
	},
	iconShellDisabled: {
		backgroundColor: colors.surfaceSoft,
	},
	icon: {
		width: 20,
		height: 20,
		resizeMode: 'contain',
	},
	textBlock: {
		flex: 1,
		minWidth: 0,
	},
	rowTitle: {
		color: colors.text,
		fontSize: 15,
		fontWeight: '600',
	},
	rowTitleDisabled: {
		color: colors.disabled,
	},
	rowDescription: {
		color: colors.textMuted,
		fontSize: 12,
		lineHeight: 17,
		marginTop: 2,
	},
});
