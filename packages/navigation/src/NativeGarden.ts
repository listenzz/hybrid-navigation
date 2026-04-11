import { TurboModuleRegistry } from 'react-native';
import type { CodegenTypes, TurboModule } from 'react-native';

export interface Spec extends TurboModule {
	getConstants: () => {
		TOOLBAR_HEIGHT: number;
	};

	setStyle: (style: CodegenTypes.UnsafeObject) => void;
	updateOptions: (sceneId: string, options: CodegenTypes.UnsafeObject) => void;
	updateTabBar: (sceneId: string, item: CodegenTypes.UnsafeObject) => void;
	setTabItem: (sceneId: string, item: Array<CodegenTypes.UnsafeObject>) => void;
	setMenuInteractive: (sceneId: string, enabled: boolean) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('HBDNativeGarden');
