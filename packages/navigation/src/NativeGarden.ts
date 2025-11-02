import { TurboModuleRegistry } from 'react-native';
import type { CodegenTypes, TurboModule } from 'react-native';

export interface Spec extends TurboModule {
	getConstants: () => {
		TOOLBAR_HEIGHT: number;
	};

	setStyle: (style: CodegenTypes.UnsafeObject) => void;
	setTitleItem: (sceneId: string, item: CodegenTypes.UnsafeObject) => void;
	setLeftBarButtonItem: (sceneId: string, item: CodegenTypes.UnsafeObject | null) => void;
	setRightBarButtonItem: (sceneId: string, item: CodegenTypes.UnsafeObject | null) => void;
	setLeftBarButtonItems: (
		sceneId: string,
		items: Array<CodegenTypes.UnsafeObject> | null,
	) => void;
	setRightBarButtonItems: (
		sceneId: string,
		items: Array<CodegenTypes.UnsafeObject> | null,
	) => void;
	updateOptions: (sceneId: string, options: CodegenTypes.UnsafeObject) => void;
	updateTabBar: (sceneId: string, item: CodegenTypes.UnsafeObject) => void;
	setTabItem: (sceneId: string, item: Array<CodegenTypes.UnsafeObject>) => void;
	setMenuInteractive: (sceneId: string, enabled: boolean) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NativeGarden');
