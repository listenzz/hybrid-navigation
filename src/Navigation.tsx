import React, { useState, useEffect, useCallback, useRef } from 'react';
import { TouchableOpacity, Text, View, ScrollView, Image, TextInput } from 'react-native';

import styles from './Styles';
import Navigation, {
	RESULT_OK,
	withNavigationItem,
	useVisible,
	NavigationProps,
	useVisibleEffect,
	RESULT_BLOCK,
} from 'hybrid-navigation';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default withNavigationItem({
	//topBarStyle: 'light-content',
	//topBarColor: '#666666',
	//topBarTintColor: '#ffffff',
	//titleTextColor: '#ffffff',

	titleItem: {
		title: 'RN navigation',
	},

	tabItem: {
		title: 'Navigation',
		icon: Image.resolveAssetSource(require('./images/navigation.png')),
	},
})(NavigationScreen);

interface Props extends NavigationProps {
	popToId?: string;
}

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

	const inputRef = useRef<TextInput>(null);
	useVisibleEffect(
		useCallback(() => {
			console.log('----blur input----');
			inputRef.current?.blur();
		}, []),
	);

	const visible = useVisible();
	useEffect(() => {
		Navigation.setMenuInteractive(sceneId, isRoot && visible);
	}, [visible, isRoot, sceneId]);

	useEffect(() => {
		console.info(`Page Navigation mounted [${sceneId}]`);
		return () => {
			console.info(`Page Navigation unmounted [${sceneId}]`);
		};
	}, [sceneId]);

	useVisibleEffect(
		useCallback(() => {
			console.info(`Page Navigation is visible [${sceneId}]`);
			return () => console.info(`Page Navigation is invisible [${sceneId}]`);
		}, [sceneId]),
	);

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
		const [_, data] = await navigator.push('Navigation', props);
		if (data) {
			setText(data.backId || undefined);
		}
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
		console.log(`Navigation result [${sceneId}]`, resultCode, data);
		if (resultCode === RESULT_OK) {
			setText(data?.text);
			setError(undefined);
		} else {
			setText(undefined);
			setError('ACTION CANCEL');
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
		testAwaitResult();
	}

	async function testAwaitResult() {
		while (true) {
			const [resultCode, data] = await navigator.present<{ text?: string }>('Result');
			if (resultCode === RESULT_BLOCK) {
				const route = await Navigation.currentRoute();
				console.info('----testAwaitResult----', JSON.stringify(route));
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
		return <Text style={styles.result}>{error}</Text>;
	}

	const [input, setInput] = useState<string>();

	function handleTextChanged(txt: string) {
		setInput(txt);
	}

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={false}
			contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}
			contentContainerStyle={{ flexGrow: 1 }}
		>
			<View style={styles.container}>
				<Text style={styles.welcome}>This's a React Native scene.</Text>
				<TouchableOpacity onPress={push} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>push</Text>
				</TouchableOpacity>
				<TouchableOpacity
					onPress={pop}
					activeOpacity={0.2}
					style={styles.button}
					disabled={isRoot}
				>
					<Text style={isRoot ? styles.buttonTextDisable : styles.buttonText}>pop</Text>
				</TouchableOpacity>

				<TouchableOpacity
					onPress={popTo}
					activeOpacity={0.2}
					style={styles.button}
					disabled={popToId === undefined}
				>
					<Text
						style={popToId === undefined ? styles.buttonTextDisable : styles.buttonText}
					>
						popTo first
					</Text>
				</TouchableOpacity>

				<TouchableOpacity
					onPress={popToRoot}
					activeOpacity={0.2}
					style={styles.button}
					disabled={isRoot}
				>
					<Text style={isRoot ? styles.buttonTextDisable : styles.buttonText}>
						popToRoot
					</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={redirectTo} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>redirectTo</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={present} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>present</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={switchTab} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>switch to tab 'Options'</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={showModal} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>show modal</Text>
				</TouchableOpacity>

				<TouchableOpacity
					onPress={printRouteGraph}
					activeOpacity={0.2}
					style={styles.button}
				>
					<Text style={styles.buttonText}>printRouteGraph</Text>
				</TouchableOpacity>
				{renderResult()}
				{renderError()}
			</View>
			<TextInput
				ref={inputRef}
				style={[styles.input2, { marginBottom: insets.bottom || 16 }]}
				onChangeText={handleTextChanged}
				autoFocus={false}
				value={input}
				placeholder={'test keyboard instes'}
				textAlignVertical="center"
			/>
		</ScrollView>
	);
}
