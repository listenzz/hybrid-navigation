import { Visibility } from '../Route';
import NativeEvent from '../NativeEvent';

export type VisibilityEventListener = (visibility: Visibility) => void;
export type GlobalVisibilityEventListener = (sceneId: string, visibility: Visibility) => void;

export default class VisibilityEventHandler {
	private listeners: Record<string, VisibilityEventListener[]> = {};
	private globalListeners: GlobalVisibilityEventListener[] = [];

	constructor() {}

	handleComponentVisibility() {
		NativeEvent.onComponentAppear(({ sceneId }) => {
			const listeners = this.listeners[sceneId];
			if (listeners) {
				listeners.forEach(listener => listener('visible'));
			}

			this.globalListeners.forEach(listener => listener(sceneId, 'visible'));
		});
		NativeEvent.onComponentDisappear(({ sceneId }) => {
			const listeners = this.listeners[sceneId];
			if (listeners) {
				listeners.forEach(listener => listener('invisible'));
			}

			this.globalListeners.forEach(listener => listener(sceneId, 'invisible'));
		});
	}

	addGlobalVisibilityEventListener(listener: GlobalVisibilityEventListener) {
		this.globalListeners.push(listener);
	}

	removeGlobalVisibilityEventListener(listener: GlobalVisibilityEventListener) {
		this.globalListeners = this.globalListeners.filter(l => l !== listener);
	}

	addVisibilityEventListener(sceneId: string, listener: VisibilityEventListener) {
		if (!this.listeners[sceneId]) {
			this.listeners[sceneId] = [];
		}
		this.listeners[sceneId].push(listener);
	}

	removeVisibilityEventListener(sceneId: string, listener: VisibilityEventListener) {
		if (this.listeners[sceneId]) {
			this.listeners[sceneId] = this.listeners[sceneId].filter(l => l !== listener);
		}
	}
}
