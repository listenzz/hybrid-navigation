import { StyleSheet } from 'react-native';

import demoTheme from './Theme';

const { colors, radius } = demoTheme;

export default StyleSheet.create({
	screen: {
		flex: 1,
		backgroundColor: colors.background,
	},

	container: {
		flex: 1,
		justifyContent: 'flex-start',
		alignItems: 'stretch',
		backgroundColor: colors.background,
		paddingHorizontal: 16,
		paddingTop: 18,
		paddingBottom: 24,
	},

	scrollContent: {
		flexGrow: 1,
	},

	result: {
		marginTop: 12,
		marginHorizontal: 4,
		paddingLeft: 10,
		borderLeftWidth: 3,
		borderLeftColor: colors.primaryMuted,
		color: colors.textBody,
		fontSize: 13,
		lineHeight: 18,
	},

	resultError: {
		borderLeftColor: colors.danger,
		color: colors.textMuted,
	},

	input: {
		minHeight: 46,
		paddingHorizontal: 14,
		paddingVertical: 0,
		color: colors.text,
		fontSize: 15,
	},

	inputPanel: {
		backgroundColor: colors.surface,
		padding: 12,
	},

	inputFrame: {
		minHeight: 48,
		justifyContent: 'center',
		borderRadius: radius.md,
		borderWidth: StyleSheet.hairlineWidth,
		borderColor: colors.border,
		backgroundColor: colors.background,
	},

	inputFrameFocused: {
		borderColor: colors.primary,
		backgroundColor: colors.surface,
	},

	input2: {
		flex: 1,
		height: 42,
		paddingHorizontal: 10,
		paddingVertical: 0,
		color: colors.text,
		fontSize: 14,
	},

	bottomInputFrame: {
		minHeight: 44,
		flexDirection: 'row',
		alignItems: 'center',
		marginTop: 8,
		marginHorizontal: 16,
		paddingHorizontal: 10,
		borderRadius: radius.sm,
		backgroundColor: colors.surfaceSoft,
	},

	bottomInputFrameFocused: {
		backgroundColor: colors.surfaceSoft,
	},

	bottomInputMarker: {
		width: 6,
		height: 6,
		borderRadius: 3,
		backgroundColor: colors.iconMuted,
	},

	bottomInputMarkerFocused: {
		backgroundColor: colors.primary,
	},

	keyboard: {
		position: 'absolute',
		left: 0,
		right: 0,
		bottom: 0,
		backgroundColor: colors.background,
	},

	keyboardFocused: {
		paddingTop: 40,
	},
});
