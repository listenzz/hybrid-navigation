import { NativeModules, NativeModule } from 'react-native'

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

const GardenModule: GardenModule = NativeModules.GardenModule

export default GardenModule
