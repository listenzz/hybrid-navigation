import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
	getConstants: () => {
		TOOLBAR_HEIGHT: number;
	};

	setStyle: (style: {}) => void;
	setTitleItem: (sceneId: string, item: {}) => void;
	setLeftBarButtonItem: (sceneId: string, item: {} | null) => void;
	setRightBarButtonItem: (sceneId: string, item: {} | null) => void;
	setLeftBarButtonItems: (sceneId: string, items: Array<{}> | null) => void;
	setRightBarButtonItems: (sceneId: string, items: Array<{}> | null) => void;
	updateOptions: (sceneId: string, options: {}) => void;
	updateTabBar: (sceneId: string, item: {}) => void;
	setTabItem: (sceneId: string, item: Array<{}>) => void;
	setMenuInteractive: (sceneId: string, enabled: boolean) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NativeGarden');
