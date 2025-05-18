import { NativeModules, NativeModule, NativeEventEmitter, Platform } from 'react-native';

interface GardenModule extends NativeModule {
  getConstants: () => {
    TOOLBAR_HEIGHT: number
    STATUSBAR_HEIGHT: number
    EVENT_STATUSBAR_FRAME_CHANGE: string
  }

  setStyle: (style: object) => void
  setTitleItem: (sceneId: string, item: object) => void
  setLeftBarButtonItem: (sceneId: string, item: object | null) => void
  setRightBarButtonItem: (sceneId: string, item: object | null) => void
  setLeftBarButtonItems: (sceneId: string, item: object | null) => void
  setRightBarButtonItems: (sceneId: string, item: object | null) => void
  updateOptions: (sceneId: string, options: object) => void
  updateTabBar: (sceneId: string, item: object) => void
  setTabItem: (sceneId: string, item: object) => void
  setMenuInteractive: (sceneId: string, enabled: boolean) => void
}

const GardenModule: GardenModule = NativeModules.GardenModule;

const { STATUSBAR_HEIGHT, TOOLBAR_HEIGHT, EVENT_STATUSBAR_FRAME_CHANGE } =
  GardenModule.getConstants();

let _statusBarHeight = STATUSBAR_HEIGHT;

if (Platform.OS === 'ios') {
  const GardenEventReceiver = new NativeEventEmitter(GardenModule);
  GardenEventReceiver.addListener(EVENT_STATUSBAR_FRAME_CHANGE, ({ statusBarHeight: height }) => {
    _statusBarHeight = height;
  });
}

function statusBarHeight() {
  return _statusBarHeight;
}

function toolbarHeight() {
  return TOOLBAR_HEIGHT;
}

function topBarHeight() {
  return statusBarHeight() + toolbarHeight();
}

export { statusBarHeight, toolbarHeight, topBarHeight };

export default GardenModule;
