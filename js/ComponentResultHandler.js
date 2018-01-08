import { DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';
import Q from 'q';

const EventEmitter = Platform.select({
    ios: new NativeEventEmitter(NavigationModule),
    android: DeviceEventEmitter,
});

EventEmitter.addListener('ON_COMPONENT_RESULT', (event) => {
    const defer = ComponentResultHandler.defers[event.requestCode];
    if (defer) {
        let data = event.data && JSON.stringify(event.data);
        defer.resolve({ code: event.resultCode, data });
    }
    delete ComponentResultHandler.defers[event.requestCode];
});

export default class ComponentResultHandler {
    static defers = {} ;

    static requestCodeCounter = 0;

    static getRequestCode() {
        return ComponentResultHandler.requestCodeCounter++;
    }

    static register(requestCode) {
        const defer = Q.defer();
        ComponentResultHandler.defers[requestCode] = defer;
        return defer.promise;
    }
}