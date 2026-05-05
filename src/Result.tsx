import React, { useState, useEffect } from 'react';
import { TextInput, ScrollView, View } from 'react-native';
import styles from './Styles';
import { DemoActionRow, DemoSection } from './DemoUI';

import Navigation, {
	RESULT_OK,
	withNavigationItem,
	NavigationProps,
	useVisibleEffect,
	BarStyleDarkContent,
} from 'hybrid-navigation';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import TopBar from './TopBar';
import demoTheme from './Theme';

export default withNavigationItem({
	statusBarStyle: BarStyleDarkContent,
})(Result);

const icons = {
	push: require('./images/action_push.png'),
	home: require('./images/action_home.png'),
	send: require('./images/action_send.png'),
	present: require('./images/action_present.png'),
	modal: require('./images/action_modal.png'),
	graph: require('./images/action_graph.png'),
};

function Result({ navigator, sceneId }: NavigationProps) {
	const [text, setText] = useState('');
	const [isRoot, setIsRoot] = useState(false);
	const [inputFocused, setInputFocused] = useState(false);
	const insets = useSafeAreaInsets();

	useEffect(() => {
		navigator.isStackRoot().then(root => {
			setIsRoot(root);
		});
	}, [navigator]);

	useVisibleEffect(() => {
		console.info(`Page Result is visible [${sceneId}]`);
		return () => console.info(`Page Result is invisible [${sceneId}]`);
	});

	function popToRoot() {
		navigator.popToRoot();
	}

	function pushToReact() {
		navigator.push('Result');
	}

	async function sendResult() {
		navigator.setResult(RESULT_OK, {
			text: text || '',
		});
		await navigator.dismiss();
	}

	function handleTextChanged(value: string) {
		setText(value);
	}

	async function present() {
		await navigator.present('Result');
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

	return (
		<View style={styles.screen}>
			<TopBar
				title="RN result"
				navigator={navigator}
				rightAction={
					isRoot
						? {
								label: 'Cancel',
								accessibilityLabel: 'Cancel',
								icon: require('./images/cancel.png'),
								onPress: () => {
									navigator.dismiss();
								},
						  }
						: undefined
				}
			/>
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
				contentContainerStyle={[
					styles.container,
					{ paddingBottom: insets.bottom > 0 ? insets.bottom : 16 },
				]}
			>
				<DemoSection title="Return value">
					<View style={styles.inputPanel}>
						<View style={[styles.inputFrame, inputFocused && styles.inputFrameFocused]}>
							<TextInput
								style={styles.input}
								onChangeText={handleTextChanged}
								onFocus={() => setInputFocused(true)}
								onBlur={() => setInputFocused(false)}
								value={text}
								placeholder={'Enter your text'}
								placeholderTextColor={demoTheme.colors.textSubtle}
								selectionColor={demoTheme.colors.primary}
								textAlignVertical="center"
								underlineColorAndroid="transparent"
							/>
						</View>
					</View>
				</DemoSection>

				<DemoSection title="Actions">
					<DemoActionRow
						icon={icons.push}
						title="Push result scene"
						description="Open another Result scene on this stack."
						onPress={pushToReact}
					/>
					<DemoActionRow
						icon={icons.home}
						title="Pop to home"
						description="Return to the root scene when possible."
						onPress={popToRoot}
						disabled={isRoot}
					/>
					<DemoActionRow
						icon={icons.send}
						title="Send data back"
						description="Dismiss and return the current input text."
						onPress={sendResult}
					/>
					<DemoActionRow
						icon={icons.present}
						title="Present"
						description="Present another Result scene."
						onPress={present}
					/>
					<DemoActionRow
						icon={icons.modal}
						title="Show modal"
						description="Open the custom React bottom modal."
						onPress={showModal}
					/>
					<DemoActionRow
						icon={icons.graph}
						title="Print route graph"
						description="Log the current route graph and active route."
						onPress={printRouteGraph}
					/>
				</DemoSection>
			</ScrollView>
		</View>
	);
}
