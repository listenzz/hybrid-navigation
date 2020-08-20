import { Navigator } from './Navigator'
import { EmitterSubscription } from 'react-native'

const navigators = new Map<string, Navigator>()
let events: EmitterSubscription[] = []

function addNavigator(sceneId: string, navigator: Navigator) {
  navigators.set(sceneId, navigator)
}

function removeNavigator(sceneId: string) {
  navigators.delete(sceneId)
}

function getNavigator(sceneId: string) {
  return navigators.get(sceneId)
}

function addBarButtonItemClickEvent(event: EmitterSubscription) {
  events.push(event)
}

function removeBarButtonItemClickEvent(event: EmitterSubscription) {
  event.remove()
  events = events.filter((e) => e !== event)
}

function filterBarButtonItemClickEvent(callback: (event: EmitterSubscription) => boolean) {
  return events.filter(callback)
}

function clear() {
  navigators.clear()

  events.forEach((event) => {
    event.remove()
  })
  events = []
}

const propsRegistry = new Map<string, object>()

function setProps(moduleName: string, props: object) {
  propsRegistry.set(moduleName, props)
}

function getProps(moduleName: string) {
  return propsRegistry.get(moduleName)
}

function deleteProps(moduleName: string) {
  propsRegistry.delete(moduleName)
}

const reactModules = new Set<string>()

function registerReactModule(moduleName: string) {
  reactModules.add(moduleName)
}

function isReactModule(moduleName: string) {
  return reactModules.has(moduleName)
}

export default {
  addNavigator,
  removeNavigator,
  getNavigator,
  addBarButtonItemClickEvent,
  removeBarButtonItemClickEvent,
  filterBarButtonItemClickEvent,
  clear,
  setProps,
  getProps,
  deleteProps,
  registerReactModule,
  isReactModule,
}
