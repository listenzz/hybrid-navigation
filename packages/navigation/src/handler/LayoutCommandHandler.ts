import NavigationModule from '../NavigationModule';
import { BuildInLayout, Layout } from '../Route';
import NativeEvent from '../NativeEvent';

export default class LayoutCommandHandler {
	private willSetRoot = () => {};
	private didSetRoot = () => {};

	constructor() {}

	handleRootLayoutChange() {
		NativeEvent.willSetRoot(() => {
			this.willSetRoot();
		});
		NativeEvent.didSetRoot(() => {
			this.didSetRoot();
		});
	}

	setRoot(layout: BuildInLayout | Layout, sticky = false) {
		return NavigationModule.setRoot(layout, sticky);
	}

	setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
		this.willSetRoot = willSetRoot;
		this.didSetRoot = didSetRoot;
	}
}
