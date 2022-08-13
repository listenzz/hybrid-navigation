import { NativeModules } from 'react-native'
import { Route, RouteGraph } from './Route'

type Callback = (error: never, result: any) => void

interface NavigationModule {
  getConstants: () => {
    RESULT_OK: number
    RESULT_CANCEL: number
  }

  startRegisterReactComponent: () => void
  endRegisterReactComponent: () => void
  registerReactComponent: (appKey: string, options: object) => void
  signalFirstRenderComplete: (sceneId: string) => void
  setRoot: (layout: object, sticky: boolean, tag: number) => void
  setResult: (sceneId: string, resultCode: number, data: object | null) => void
  dispatch: (sceneId: string, action: string, params: object, callback: Callback) => void
  currentTab: (sceneId: string, callback: Callback) => void
  isStackRoot: (sceneId: string, callback: Callback) => void
  findSceneIdByModuleName: (moduleName: string, callback: Callback) => void
  currentRoute: (callback: Callback) => void
  routeGraph: (callback: Callback) => void
}

const NavigationModule: NavigationModule = NativeModules.NavigationModule

function getConstants() {
  return NavigationModule.getConstants()
}

function startRegisterReactComponent() {
  NavigationModule.startRegisterReactComponent()
}

function endRegisterReactComponent() {
  NavigationModule.endRegisterReactComponent()
}

function registerReactComponent(appKey: string, options: object) {
  NavigationModule.registerReactComponent(appKey, options)
}

function signalFirstRenderComplete(sceneId: string) {
  NavigationModule.signalFirstRenderComplete(sceneId)
}

function setResult(sceneId: string, resultCode: number, data: object | null) {
  NavigationModule.setResult(sceneId, resultCode, data)
}

function setRoot(layout: object, sticky: boolean, tag: number) {
  NavigationModule.setRoot(layout, sticky, tag)
}

function dispatch(sceneId: string, action: string, params: object) {
  return new Promise<boolean>(resolve => {
    NavigationModule.dispatch(sceneId, action, params, (_, result) => {
      resolve(result)
    })
  })
}

function currentTab(sceneId: string) {
  return new Promise<number>(resolve => {
    NavigationModule.currentTab(sceneId, (_, result) => {
      resolve(result)
    })
  })
}

function isStackRoot(sceneId: string) {
  return new Promise<boolean>(resolve => {
    NavigationModule.isStackRoot(sceneId, (_, result) => {
      resolve(result)
    })
  })
}

function findSceneIdByModuleName(moduleName: string) {
  return new Promise<string | null>(resolve => {
    NavigationModule.findSceneIdByModuleName(moduleName, (_, result) => {
      resolve(result)
    })
  })
}

function currentRoute() {
  return new Promise<Route>(resolve => {
    NavigationModule.currentRoute((_, result) => {
      resolve(result)
    })
  })
}

function routeGraph() {
  return new Promise<RouteGraph[]>(resolve => {
    NavigationModule.routeGraph((_, result) => {
      resolve(result)
    })
  })
}

export default {
  getConstants,
  startRegisterReactComponent,
  endRegisterReactComponent,
  registerReactComponent,
  signalFirstRenderComplete,
  setResult,
  setRoot,
  dispatch,
  currentTab,
  isStackRoot,
  findSceneIdByModuleName,
  currentRoute,
  routeGraph,
}
