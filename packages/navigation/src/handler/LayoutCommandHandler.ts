import { BuildInLayout, Layout } from '../Route';
import NativeEvent from '../NativeEvent';
import NativeNavigation from '../NativeNavigation';

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
		return new Promise<boolean>(resolve => {
			NativeNavigation.setRoot(layout, sticky, (_, success) => {
				resolve(success);
			});
		});
	}

	setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
		this.willSetRoot = willSetRoot;
		this.didSetRoot = didSetRoot;
	}
}
