import React, { useEffect } from 'react';
import { View, Text, StyleSheet, TouchableHighlight } from 'react-native';
import withBottomModal from './withBottomModal';
import demoTheme from './Theme';
import Navigation, {
	RESULT_OK,
	NavigationProps,
	useVisibleEffect,
	withNavigationItem,
} from 'hybrid-navigation';

function ReactModal({ navigator, sceneId }: NavigationProps) {
	useEffect(() => {
		navigator.setResult(RESULT_OK, {
			text: 'Are you male or female?',
			backId: sceneId,
		});
	}, [navigator, sceneId]);

	useVisibleEffect(() => {
		console.info(`Page ReactModal is visible [${sceneId}]`);
		return () => console.info(`Page ReactModal is invisible [${sceneId}]`);
	});

	async function hideModal(gender?: string) {
		if (gender) {
			navigator.setResult(RESULT_OK, {
				text: gender,
				backId: sceneId,
			});
		}
		await navigator.hideModal();
	}

	async function showModal() {
		await navigator.showModal('ReactModal');
	}

	async function printRouteGraph() {
		const graph = await Navigation.routeGraph();
		console.log(JSON.stringify(graph, null, 2));
		const route = await Navigation.currentRoute();
		console.log(JSON.stringify(route, null, 2));
	}

	function handleCancel() {
		hideModal();
	}

	const actionSheets = [
		{
			text: 'Male',
			onPress: () => {
				hideModal('Male');
			},
		},
		{
			text: 'Female',
			onPress: () => {
				hideModal('Female');
			},
		},
		{
			text: 'showModal',
			onPress: () => {
				showModal();
			},
		},
		{
			text: 'printRouteGraph',
			onPress: () => {
				printRouteGraph();
			},
		},
	];

	const renderItem = (text: string, onPress: () => void) => {
		return (
			<TouchableHighlight onPress={onPress} underlayColor={demoTheme.colors.surfaceActive}>
				<View style={styles.item}>
					<Text style={styles.itemText}>{text}</Text>
				</View>
			</TouchableHighlight>
		);
	};

	return (
		<View style={styles.container}>
			{actionSheets.map(({ text, onPress }, index) => {
				const isLast = index === actionSheets.length - 1;
				return (
					<View key={text} style={!isLast && styles.divider}>
						{renderItem(text, onPress)}
					</View>
				);
			})}
			<View style={styles.itemCancel}>{renderItem('Cancel', handleCancel)}</View>
		</View>
	);
}

export default withBottomModal({ safeAreaColor: demoTheme.colors.background })(
	withNavigationItem({
		// screenBackgroundColor: '#33000000',
	})(ReactModal),
);

const styles = StyleSheet.create({
	container: {
		backgroundColor: demoTheme.colors.surfaceSoft,
		paddingTop: 10,
		borderTopLeftRadius: demoTheme.radius.lg,
		borderTopRightRadius: demoTheme.radius.lg,
		overflow: 'hidden',
	},
	item: {
		height: 52,
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: demoTheme.colors.background,
	},
	divider: {
		borderBottomWidth: StyleSheet.hairlineWidth,
		borderBottomColor: demoTheme.colors.border,
	},
	itemCancel: {
		marginTop: 10,
		backgroundColor: demoTheme.colors.background,
	},
	itemText: {
		fontSize: 16,
		fontWeight: '600',
		color: demoTheme.colors.dark,
	},
});
