import {NativeModules, NativeModule, NativeEventEmitter} from 'react-native';

interface Constants {
	BACKGROUND_TASK_EVENT: string;
}

interface BackgroundTaskInterface extends NativeModule {
	getConstants(): Constants;
	scheduleTask(): void;
}

const BackgroundTask: BackgroundTaskInterface = NativeModules.BackgroundTask;
const EventEmitter: NativeEventEmitter = new NativeEventEmitter(BackgroundTask);

export {EventEmitter};
export default BackgroundTask;
