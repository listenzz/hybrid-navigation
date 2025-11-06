import { Navigator } from './Navigator';

const navigators = new Map<string, Navigator>();

function addNavigator(sceneId: string, navigator: Navigator) {
	navigators.set(sceneId, navigator);
}

function removeNavigator(sceneId: string) {
	navigators.delete(sceneId);
}

function getNavigator(sceneId: string) {
	return navigators.get(sceneId);
}

export default {
	addNavigator,
	removeNavigator,
	getNavigator,
};
