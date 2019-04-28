import { EventEmitter, NavigationModule, EVENT_SET_ROOT_COMPLETED, EVENT_SWITCH_TAB, KEY_SCENE_ID, KEY_INDEX, KEY_MODULE_NAME, } from './NavigationModule';
import { bindBarButtonItemClickEvent } from './utils';
import store from './store';
let intercept;
let willSetRootCallback;
let didSetRootEventSubscription;
let didSetRootCallback;
let shouldSwitchTabSubscription;
export class Navigator {
    constructor(sceneId, moduleName) {
        this.sceneId = sceneId;
        this.moduleName = moduleName;
        this.state = { params: {} };
        this.sceneId = sceneId;
        this.moduleName = moduleName;
        this.dispatch = this.dispatch.bind(this);
        this.setParams = this.setParams.bind(this);
        this.push = this.push.bind(this);
        this.pop = this.pop.bind(this);
        this.popTo = this.popTo.bind(this);
        this.popToRoot = this.popToRoot.bind(this);
        this.replace = this.replace.bind(this);
        this.replaceToRoot = this.replaceToRoot.bind(this);
        this.isRoot = this.isRoot.bind(this);
        this.isStackRoot = this.isStackRoot.bind(this);
        this.present = this.present.bind(this);
        this.dismiss = this.dismiss.bind(this);
        this.showModal = this.showModal.bind(this);
        this.hideModal = this.hideModal.bind(this);
        this.setResult = this.setResult.bind(this);
        this.toggleMenu = this.toggleMenu.bind(this);
        this.openMenu = this.openMenu.bind(this);
        this.closeMenu = this.closeMenu.bind(this);
    }
    static get(sceneId) {
        return store.getNavigator(sceneId) || new Navigator(sceneId);
    }
    static async current() {
        const route = await Navigator.currentRoute();
        if (route) {
            return Navigator.get(route.sceneId);
        }
        return null;
    }
    static async currentRoute() {
        return await NavigationModule.currentRoute();
    }
    static async routeGraph() {
        return await NavigationModule.routeGraph();
    }
    static setRoot(layout, sticky = false) {
        if (willSetRootCallback) {
            willSetRootCallback();
        }
        if (didSetRootEventSubscription) {
            didSetRootEventSubscription.remove();
        }
        didSetRootEventSubscription = EventEmitter.addListener(EVENT_SET_ROOT_COMPLETED, _ => {
            if (didSetRootCallback) {
                didSetRootCallback();
            }
        });
        if (shouldSwitchTabSubscription) {
            shouldSwitchTabSubscription.remove();
        }
        shouldSwitchTabSubscription = EventEmitter.addListener(EVENT_SWITCH_TAB, event => {
            Navigator.dispatch(event[KEY_SCENE_ID], 'switchTab', {
                index: event[KEY_INDEX],
                moduleName: event[KEY_MODULE_NAME],
            });
        });
        const pureLayout = bindBarButtonItemClickEvent(layout, {
            inLayout: true,
            navigatorFactory: (sceneId) => {
                return new Navigator(sceneId);
            },
        });
        NavigationModule.setRoot(pureLayout, sticky);
    }
    static setRootLayoutUpdateListener(willSetRoot = () => { }, didSetRoot = () => { }) {
        willSetRootCallback = willSetRoot;
        didSetRootCallback = didSetRoot;
    }
    static dispatch(sceneId, action, params = {}) {
        const navigator = Navigator.get(sceneId);
        if (!intercept ||
            !intercept(action, navigator.moduleName, params.moduleName, { sceneId, index: params.index })) {
            NavigationModule.dispatch(sceneId, action, params);
        }
    }
    static setInterceptor(interceptor) {
        intercept = interceptor;
    }
    setParams(params) {
        this.state.params = { ...this.state.params, ...params };
    }
    dispatch(action, params = {}) {
        Navigator.dispatch(this.sceneId, action, params);
    }
    push(moduleName, props = {}, options = {}, animated = true) {
        this.dispatch('push', { moduleName, props, options, animated });
    }
    pushLayout(layout, animated = true) {
        this.dispatch('pushLayout', { layout, animated });
    }
    pop(animated = true) {
        this.dispatch('pop', { animated });
    }
    popTo(sceneId, animated = true) {
        this.dispatch('popTo', { animated, targetId: sceneId });
    }
    popToRoot(animated = true) {
        this.dispatch('popToRoot', { animated });
    }
    replace(moduleName, props = {}, options = {}) {
        this.dispatch('replace', { moduleName, props, options, animated: true });
    }
    replaceToRoot(moduleName, props = {}, options = {}) {
        this.dispatch('replaceToRoot', { moduleName, props, options, animated: true });
    }
    isRoot() {
        console.warn('isRoot is deprecated, use isStackRoot instead.');
        return NavigationModule.isNavigationRoot(this.sceneId);
    }
    isStackRoot() {
        return NavigationModule.isNavigationRoot(this.sceneId);
    }
    present(moduleName, requestCode = 0, props = {}, options = {}, animated = true) {
        this.dispatch('present', {
            moduleName,
            props,
            options,
            requestCode,
            animated,
        });
    }
    presentLayout(layout, requestCode = 0, animated = true) {
        this.dispatch('presentLayout', { layout, requestCode, animated });
    }
    dismiss(animated = true) {
        this.dispatch('dismiss', { animated });
    }
    showModal(moduleName, requestCode = 0, props = {}, options = {}) {
        this.dispatch('showModal', {
            moduleName,
            props,
            options,
            requestCode,
        });
    }
    showModalLayout(layout, requestCode = 0) {
        this.dispatch('showModalLayout', { layout, requestCode });
    }
    hideModal() {
        this.dispatch('hideModal');
    }
    setResult(resultCode, data = {}) {
        NavigationModule.setResult(this.sceneId, resultCode, data);
    }
    switchTab(index, popToRoot = false) {
        this.dispatch('switchTab', { index, popToRoot });
    }
    toggleMenu() {
        this.dispatch('toggleMenu');
    }
    openMenu() {
        this.dispatch('openMenu');
    }
    closeMenu() {
        this.dispatch('closeMenu');
    }
    signalFirstRenderComplete() {
        NavigationModule.signalFirstRenderComplete(this.sceneId);
    }
}
Navigator.RESULT_OK = NavigationModule.RESULT_OK;
Navigator.RESULT_CANCEL = NavigationModule.RESULT_CANCEL;
