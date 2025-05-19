import {NativeModules, NativeEventEmitter, NativeModule} from 'react-native';
import type {Visibility} from './Route';
interface HBDEventEmitter extends NativeModule {
	getConstants: () => {
		EVENT_NAVIGATION: string;
		EVENT_SWITCH_TAB: string;
		EVENT_DID_SET_ROOT: string;
		EVENT_WILL_SET_ROOT: string;
		ON_COMPONENT_RESULT: string;
		ON_BAR_BUTTON_ITEM_CLICK: string;
		ON_COMPONENT_APPEAR: string;
		ON_COMPONENT_DISAPPEAR: string;
		KEY_REQUEST_CODE: string;
		KEY_RESULT_CODE: string;
		KEY_RESULT_DATA: string;
		KEY_SCENE_ID: string;
		KEY_MODULE_NAME: string;
		KEY_INDEX: string;
		KEY_ACTION: string;
		KEY_ON: string;
	};
}

const HBDEventEmitter: HBDEventEmitter = NativeModules.HBDEventEmitter;
const HBDEventReceiver = new NativeEventEmitter(HBDEventEmitter);

function listenComponentResult(
	listener: (
		sceneId: string,
		requestCode: number,
		resultCode: number,
		resultData: object,
	) => void,
) {
	const {
		EVENT_NAVIGATION,
		KEY_ON,
		ON_COMPONENT_RESULT,
		KEY_REQUEST_CODE,
		KEY_RESULT_CODE,
		KEY_RESULT_DATA,
		KEY_SCENE_ID,
	} = HBDEventEmitter.getConstants();

	return HBDEventReceiver.addListener(EVENT_NAVIGATION, data => {
		if (data[KEY_ON] === ON_COMPONENT_RESULT) {
			const requestCode = data[KEY_REQUEST_CODE];
			const resultCode = data[KEY_RESULT_CODE];
			const resultData = data[KEY_RESULT_DATA];
			const sceneId = data[KEY_SCENE_ID];

			listener(sceneId, requestCode, resultCode, resultData);
		}
	});
}

function listenComponentVisibility(listener: (sceneId: string, visibility: Visibility) => void) {
	const {EVENT_NAVIGATION, KEY_ON, ON_COMPONENT_APPEAR, ON_COMPONENT_DISAPPEAR, KEY_SCENE_ID} =
		HBDEventEmitter.getConstants();

	return HBDEventReceiver.addListener(EVENT_NAVIGATION, data => {
		if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
			listener(data[KEY_SCENE_ID], 'visible');
		}

		if (data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
			listener(data[KEY_SCENE_ID], 'invisible');
		}
	});
}

function listenBarButtonItemClick(listener: (sceneId: string, action: string) => void) {
	const {EVENT_NAVIGATION, KEY_ON, ON_BAR_BUTTON_ITEM_CLICK, KEY_ACTION, KEY_SCENE_ID} =
		HBDEventEmitter.getConstants();

	return HBDEventReceiver.addListener(
		EVENT_NAVIGATION,
		data => {
			if (data[KEY_ON] === ON_BAR_BUTTON_ITEM_CLICK) {
				listener(data[KEY_SCENE_ID], data[KEY_ACTION]);
			}
		},
		{},
	);
}

function listenTabSwitch(listener: (sceneId: string, from: number, to: number) => void) {
	const {EVENT_SWITCH_TAB, KEY_INDEX, KEY_SCENE_ID} = HBDEventEmitter.getConstants();
	return HBDEventReceiver.addListener(EVENT_SWITCH_TAB, event => {
		const index = event[KEY_INDEX];
		const [from, to] = index.split('-');
		listener(event[KEY_SCENE_ID], parseInt(from, 10), parseInt(to, 10));
	});
}

function listenWillSetRoot(willSetRoot: () => void) {
	const {EVENT_WILL_SET_ROOT} = HBDEventEmitter.getConstants();
	return HBDEventReceiver.addListener(EVENT_WILL_SET_ROOT, _ => {
		willSetRoot();
	});
}

function listenDidSetRoot(didSetRoot: (tag: number) => void) {
	const {EVENT_DID_SET_ROOT} = HBDEventEmitter.getConstants();
	return HBDEventReceiver.addListener(EVENT_DID_SET_ROOT, (event: {tag: number}) => {
		didSetRoot(event.tag);
	});
}

export default {
	listenBarButtonItemClick,
	listenComponentResult,
	listenComponentVisibility,
	listenTabSwitch,
	listenWillSetRoot,
	listenDidSetRoot,
};
