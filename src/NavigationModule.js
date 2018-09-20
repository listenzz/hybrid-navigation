import { NativeModules, DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';

const NavigationModule = NativeModules.NavigationHybrid;

const EventEmitter = Platform.select({
  ios: new NativeEventEmitter(NavigationModule),
  android: DeviceEventEmitter,
});

export { EventEmitter };

export default NavigationModule;
