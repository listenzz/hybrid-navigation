import { PropsType, NavigationItem } from '../typing'

export type RouteMode = 'modal' | 'present' | 'push'
export type LayoutMode = 'modal' | 'present' | 'normal'

export interface Route {
  sceneId: string
  moduleName: string
  mode: LayoutMode
}

export interface RouteGraph {
  layout: string
  sceneId: string
  mode: LayoutMode
  children?: RouteGraph[]
}

export interface RouteConfig {
  path?: string
  dependency?: string
  mode?: RouteMode
}

export interface RouteInfo {
  moduleName: string
  dependencies: string[]
  mode: RouteMode
  props: PropsType
  options: NavigationItem
}

export interface RouteData {
  moduleName: string
  regexp?: RegExp
  path?: string
  dependency?: string
  mode: RouteMode
}

export interface RouteHandler {
  (graph: RouteGraph, route: RouteInfo, next: RouteHandler): Promise<boolean>
}

export type RouteInterceptor = (path: string) => boolean | Promise<boolean>
