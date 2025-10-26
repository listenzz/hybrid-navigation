import { TurboModuleRegistry } from 'react-native';
import type { CodegenTypes, TurboModule } from 'react-native';

export type ComponentAppearEvent = {
	sceneId: string;
};

export type ComponentDisappearEvent = {
	sceneId: string;
};

export type BarButtonItemClickEvent = {
	sceneId: string;
	action: string;
};

export type ResultEvent = {
	sceneId: string;
	requestCode: number;
	resultCode: number;
	resultData: {};
};

export type SwitchTabEvent = {
	sceneId: string;
	from: number;
	to: number;
};

export interface Spec extends TurboModule {
	readonly onResult: CodegenTypes.EventEmitter<ResultEvent>;
	readonly willSetRoot: CodegenTypes.EventEmitter<void>;
	readonly didSetRoot: CodegenTypes.EventEmitter<void>;
	readonly onSwitchTab: CodegenTypes.EventEmitter<SwitchTabEvent>;
	readonly onBarButtonItemClick: CodegenTypes.EventEmitter<BarButtonItemClickEvent>;
	readonly onComponentAppear: CodegenTypes.EventEmitter<ComponentAppearEvent>;
	readonly onComponentDisappear: CodegenTypes.EventEmitter<ComponentDisappearEvent>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NativeEvent');
