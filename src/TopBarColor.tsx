import React from 'react';
import {Text, View, TouchableOpacity, ScrollView} from 'react-native';
import Navigation, {withNavigationItem, NavigationProps} from 'hybrid-navigation';
import styles from './Styles';

export default withNavigationItem({
	topBarColor: '#FF0000',
})(TopBarColor);

function TopBarColor({sceneId, navigator}: NavigationProps) {
	function red() {
		Navigation.updateOptions(sceneId, {topBarColor: '#FF0000'});
	}

	function green() {
		Navigation.updateOptions(sceneId, {topBarColor: '#00FF00'});
	}

	function blue() {
		Navigation.updateOptions(sceneId, {topBarColor: '#0000FF'});
	}

	function topBarColor() {
		navigator.push('TopBarColor');
	}

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="never"
			automaticallyAdjustContentInsets={false}
			contentInset={{top: 0, left: 0, bottom: 0, right: 0}}>
			<View style={styles.container}>
				<Text style={styles.welcome}>Bright colors</Text>

				<TouchableOpacity onPress={red} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>Red</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={blue} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>Blue</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={green} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>Green</Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={topBarColor} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>TopBarColor</Text>
				</TouchableOpacity>
			</View>
		</ScrollView>
	);
}
