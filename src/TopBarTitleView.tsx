/* eslint-disable react-native/no-inline-styles */
import React from 'react';
import {Text, View, TouchableOpacity, ScrollView, Alert, Image} from 'react-native';
import {LayoutFittingExpanded, NavigationProps, NavigationItem} from 'hybrid-navigation';
import styles from './Styles';
import {Lifecycle, withLifecycle} from './withLifecycle';

function CustomTitleView(props: NavigationProps) {
	let {params} = props.navigator.state;
	return (
		<View
			style={{
				flex: 1,
				flexDirection: 'row',
				justifyContent: 'center',
				alignItems: 'center',
			}}>
			<Text style={{fontSize: 17, fontWeight: 'bold'}}>--Custom Title--</Text>
			<TouchableOpacity onPress={params.onFackbookButtonClick}>
				<Image
					style={{width: 24, height: 24}}
					source={{
						uri: 'https://facebook.github.io/react-native/docs/assets/favicon.png',
					}}
				/>
			</TouchableOpacity>
		</View>
	);
}

export {CustomTitleView};

class TopBarTitleView extends React.Component<NavigationProps> implements Lifecycle {
	static navigationItem: NavigationItem = {
		backButtonHidden: true,
		titleItem: {
			// registered component name
			moduleName: 'CustomTitleView',
			// `LayoutFittingExpanded` or `LayoutFittingCompressed`, default is `LayoutFittingExpanded`
			layoutFitting: LayoutFittingExpanded,
		},
	};

	constructor(props: NavigationProps) {
		super(props);
		this.topBarTitleView = this.topBarTitleView.bind(this);
		this.props.navigator.setParams({
			onFackbookButtonClick: this.onFackbookButtonClick.bind(this),
		});
	}

	componentDidAppear() {
		console.info('TopBarTitleView#componentDidAppear');
	}

	componentDidDisappear() {
		console.info('TopBarTitleView#componentDidDisAppear');
	}

	onFackbookButtonClick() {
		Alert.alert(
			'Hello!',
			'React button is clicked.',
			[{text: 'OK', onPress: () => console.log('OK Pressed')}],
			{
				cancelable: false,
			},
		);
	}

	topBarTitleView() {
		this.props.navigator.push('TopBarTitleView');
	}

	render() {
		return (
			<ScrollView
				contentInsetAdjustmentBehavior="never"
				automaticallyAdjustContentInsets={false}
				contentInset={{top: 0, left: 0, bottom: 0, right: 0}}>
				<View style={styles.container}>
					<Text style={styles.welcome}> Custom title bar </Text>

					<TouchableOpacity
						onPress={this.topBarTitleView}
						activeOpacity={0.2}
						style={styles.button}>
						<Text style={styles.buttonText}>TopBarTitleView</Text>
					</TouchableOpacity>
				</View>
			</ScrollView>
		);
	}
}

export default withLifecycle(TopBarTitleView);
