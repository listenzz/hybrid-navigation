import React, { useState, useEffect, useRef } from 'react';
import { Text, View, ScrollView, Image, TextInput } from 'react-native';
import { KeyboardInsetsView } from '@sdcx/keyboard-insets';

import styles from './Styles';
import { DemoActionRow, DemoSection } from './DemoUI';
import Navigation, {
	RESULT_OK,
	withNavigationItem,
	NavigationProps,
	useVisibleEffect,
	RESULT_BLOCK,
} from 'hybrid-navigation';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import TopBar from './TopBar';
import demoTheme from './Theme';

export default withNavigationItem({
	tabItem: {
		title: 'Navigation',
		icon: Image.resolveAssetSource(require('./images/navigation.png')),
	},
})(NavigationScreen);

interface Props extends NavigationProps {
	popToId?: string;
}

const icons = {
	push: require('./images/action_push.png'),
	pop: require('./images/action_pop.png'),
	home: require('./images/action_home.png'),
	redirect: require('./images/action_redirect.png'),
	present: require('./images/action_present.png'),
	modal: require('./images/action_modal.png'),
	result: require('./images/action_result.png'),
	tab: require('./images/action_tab.png'),
	graph: require('./images/action_graph.png'),
};

function NavigationScreen({ navigator, sceneId, popToId }: Props) {
	const insets = useSafeAreaInsets();
	const [text, setText] = useState<string>();
	const [error, setError] = useState<string>();
	const [isRoot, setIsRoot] = useState(false);

	useEffect(() => {
		navigator.isStackRoot().then(root => {
			setIsRoot(root);
		});
	}, [navigator]);

	useVisibleEffect(() => {
		let mounted = true;
		navigator.isStackRoot().then(root => {
			if (mounted) {
				setIsRoot(root);
			}
		});
		return () => {
			mounted = false;
		};
	});

	const inputRef = useRef<TextInput>(null);
	useVisibleEffect(() => {
		inputRef.current?.blur();
	});

	useVisibleEffect(() => {
		console.info(`Page Navigation is visible [${sceneId}]`);
		return () => console.info(`Page Navigation is invisible [${sceneId}]`);
	});

	useEffect(() => {
		console.info(`Page Navigation mounted [${sceneId}]`);
		return () => {
			console.info(`Page Navigation unmounted [${sceneId}]`);
		};
	}, [sceneId]);

	useEffect(() => {
		navigator.setResult(RESULT_OK, { backId: sceneId });
	}, [navigator, sceneId]);

	async function push() {
		let props: Partial<Props> = {};
		if (!isRoot) {
			if (popToId !== undefined) {
				props.popToId = popToId;
			} else {
				props.popToId = sceneId;
			}
		}
		await navigator.push('Navigation', props);
	}

	async function pop() {
		await navigator.pop();
	}

	async function popTo() {
		if (popToId) {
			await navigator.popTo(popToId);
		}
	}

	async function popToRoot() {
		await navigator.popToRoot();
	}

	async function redirectTo() {
		if (isRoot) {
			return;
		}
		if (popToId !== undefined) {
			await navigator.redirectTo('Navigation', {
				popToId,
			});
		} else {
			await navigator.redirectTo('Navigation');
		}
	}

	async function printRouteGraph() {
		const graph = await Navigation.routeGraph();
		console.log(JSON.stringify(graph, null, 2));
		const route = await Navigation.currentRoute();
		console.log(JSON.stringify(route, null, 2));
	}

	async function switchTab() {
		await navigator.switchTab(1);
	}

	function handleResult(resultCode: number, data: { text?: string }) {
		if (resultCode === RESULT_OK) {
			setText(data?.text);
			setError(undefined);
		} else {
			setText(undefined);
			setError('Action canceled.');
		}
	}

	async function present() {
		const [resultCode, data] = await navigator.present<{ text?: string }>('Result');
		handleResult(resultCode, data);
	}

	function showModal() {
		(async function show() {
			const [resultCode, data] = await navigator.showModal<{
				text?: string;
			}>('ReactModal');
			handleResult(resultCode, data);
		})();
	}

	async function testAwaitResult() {
		while (true) {
			const [resultCode, data] = await navigator.present<{ text?: string }>('Result');
			if (resultCode === RESULT_BLOCK) {
				const route = await Navigation.currentRoute();
				if (route.mode === 'modal' && route.presentingId) {
					await Navigation.result(route.presentingId, route.requestCode);
					continue;
				}
			}
			handleResult(resultCode, data);
			break;
		}
	}

	function renderResult() {
		if (text === undefined) {
			return null;
		}
		return <Text style={styles.result}>received text：{text}</Text>;
	}

	function renderError() {
		if (error === undefined) {
			return null;
		}
		return <Text style={[styles.result, styles.resultError]}>{error}</Text>;
	}

	const [input, setInput] = useState<string>();
	const [inputFocused, setInputFocused] = useState(false);
	const bottomInputSpace = insets.bottom + 82;

	function handleTextChanged(txt: string) {
		setInput(txt);
	}

	return (
		<View style={styles.screen}>
			<TopBar
				title="RN navigation"
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
				contentContainerStyle={[styles.scrollContent, { paddingBottom: bottomInputSpace }]}
			>
				<View style={styles.container}>
					<DemoSection title="Stack">
						<DemoActionRow
							icon={icons.push}
							title="Push scene"
							description="Open another Navigation scene on the current stack."
							onPress={push}
						/>
						<DemoActionRow
							icon={icons.pop}
							title="Pop scene"
							description="Go back one scene when this is not the root."
							onPress={pop}
							disabled={isRoot}
						/>
						<DemoActionRow
							icon={icons.pop}
							title="Pop to first"
							description="Return to the first pushed scene in this stack branch."
							onPress={popTo}
							disabled={popToId === undefined}
						/>
						<DemoActionRow
							icon={icons.home}
							title="Pop to root"
							description="Collapse the stack back to the root scene."
							onPress={popToRoot}
							disabled={isRoot}
						/>
						<DemoActionRow
							icon={icons.redirect}
							title="Redirect"
							description="Replace the current scene with a fresh Navigation scene."
							onPress={redirectTo}
							disabled={isRoot}
						/>
					</DemoSection>

					<DemoSection title="Presentation">
						<DemoActionRow
							icon={icons.present}
							title="Present result"
							description="Present a scene and wait for its returned text."
							onPress={present}
						/>
						<DemoActionRow
							icon={icons.modal}
							title="Show modal"
							description="Open the custom React bottom modal."
							onPress={showModal}
						/>
						<DemoActionRow
							icon={icons.result}
							title="Await modal result"
							description="Exercise the blocked-result handoff flow."
							onPress={testAwaitResult}
						/>
					</DemoSection>

					<DemoSection title="Tabs & Debug">
						<DemoActionRow
							icon={icons.tab}
							title="Switch to Options"
							description="Jump to the Options tab from the root scene."
							onPress={switchTab}
							disabled={!isRoot}
						/>
						<DemoActionRow
							icon={icons.graph}
							title="Print route graph"
							description="Log the current route graph and active route."
							onPress={printRouteGraph}
						/>
					</DemoSection>
					{renderResult()}
					{renderError()}
				</View>
			</ScrollView>
			<KeyboardInsetsView
				extraHeight={16}
				style={[styles.keyboard, inputFocused && styles.keyboardFocused]}
			>
				<View
					style={[
						styles.bottomInputFrame,
						inputFocused && styles.bottomInputFrameFocused,
						{ marginBottom: insets.bottom + 14 },
					]}
				>
					<View
						style={[
							styles.bottomInputMarker,
							inputFocused && styles.bottomInputMarkerFocused,
						]}
					/>
					<TextInput
						ref={inputRef}
						style={styles.input2}
						onChangeText={handleTextChanged}
						onFocus={() => {
							setInputFocused(true);
						}}
						onBlur={() => setInputFocused(false)}
						autoFocus={false}
						value={input}
						placeholder={'Keyboard input'}
						placeholderTextColor={demoTheme.colors.textSubtle}
						selectionColor={demoTheme.colors.primary}
						underlineColorAndroid="transparent"
					/>
				</View>
			</KeyboardInsetsView>
		</View>
	);
}
