import { Navigator } from './Navigator';
import { EmitterSubscription } from 'react-native';
declare function addNavigator(sceneId: string, navigator: Navigator): void;
declare function removeNavigator(sceneId: string): void;
declare function getNavigator(sceneId: string): Navigator | undefined;
declare function addBarButtonItemClickEvent(event: EmitterSubscription): void;
declare function removeBarButtonItemClickEvent(event: EmitterSubscription): void;
declare function filterBarButtonItemClickEvent(callback: (event: EmitterSubscription) => boolean): EmitterSubscription[];
declare function clear(): void;
declare const _default: {
    addNavigator: typeof addNavigator;
    removeNavigator: typeof removeNavigator;
    getNavigator: typeof getNavigator;
    addBarButtonItemClickEvent: typeof addBarButtonItemClickEvent;
    removeBarButtonItemClickEvent: typeof removeBarButtonItemClickEvent;
    filterBarButtonItemClickEvent: typeof filterBarButtonItemClickEvent;
    clear: typeof clear;
};
export default _default;
