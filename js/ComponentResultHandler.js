import { DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';
import Q from 'q';

const EventEmitter = Platform.select({
    ios: new NativeEventEmitter(NavigationModule),
    android: DeviceEventEmitter,
});

export default class ComponentResultHandler {
    static defers = {} ;

    static counter = 0;

    static getRequestCode() {
        return ComponentResultHandler.counter++;
    }

    static register(requestCode) {
        const defer = Q.defer();
        EventEmitter.addListener('ON_COMPONENT_RESULT', function(event) {                             
            const defer = ComponentResultHandler.defers[event.sceneId];
            if (defer) {
                let data = event.data && JSON.stringify(event.data);
                defer.resolve({ code: event.resultCode, data });
            }
        });
        return defer.promise;
    }
}