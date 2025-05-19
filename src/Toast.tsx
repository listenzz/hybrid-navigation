import React, {useEffect, useRef} from 'react';
import {Text, View, TouchableOpacity} from 'react-native';
import Toast, {useToast} from 'react-native-toast-hybrid';
import {statusBarHeight, withNavigationItem} from 'hybrid-navigation';
import styles from './Styles';

export default withNavigationItem({
	titleItem: {
		title: 'Toast',
	},
})(ToastComponent);

type Timer = ReturnType<typeof setTimeout>;

function ToastComponent() {
	const timer = useRef<Timer>(undefined);
	useEffect(() => {
		Toast.config({
			// backgroundColor: '#BB000000',
			// tintColor: '#FFFFFF',
			// cornerRadius: 5, // only for android
			// duration: 2000,
			// graceTime: 300,
			// minShowTime: 800,
			// dimAmount: 0.0, // only for andriod
			loadingText: 'Loading...',
		});
		return () => {
			if (timer.current) {
				clearTimeout(timer.current);
			}
		};
	}, []);

	const toast = useToast();

	function loading() {
		toast.loading();
		timer.current = setTimeout(() => {
			toast.done('Work is done!');
			timer.current = setTimeout(() => {
				toast.loading('New task in progress...');
				timer.current = setTimeout(() => {
					timer.current = undefined;
					toast.hide();
				}, 2000);
			}, 1500);
		}, 2000);
	}

	function text() {
		toast.text('Hello World!!');
	}

	function info() {
		toast.info(
			'A long long message to tell you, A long long message to tell you, A long long message to tell you',
		);
	}

	function done() {
		toast.done('Work is Done！');
	}

	function error() {
		toast.error('Maybe somthing is wrong！');
	}

	return (
		<View style={[styles.container, {paddingTop: statusBarHeight()}]}>
			<TouchableOpacity onPress={loading} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}> loading </Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={text} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}> text </Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={info} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}> info </Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={done} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}> done </Text>
			</TouchableOpacity>

			<TouchableOpacity onPress={error} activeOpacity={0.2} style={styles.button}>
				<Text style={styles.buttonText}> error </Text>
			</TouchableOpacity>
		</View>
	);
}
