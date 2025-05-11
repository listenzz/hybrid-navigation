export type Visibility = 'visible' | 'invisible' | 'pending'

export interface Screen extends Layout {
  screen: {
    moduleName: string
    props?: object
    options?: {}
  }
}

export interface Stack extends Layout {
  stack: {
    children: Array<BuildInLayout | Layout>
    options?: {}
  }
}

export interface Tabs extends Layout {
  tabs: {
    children: Array<BuildInLayout | Layout>
    options?: {
      selectedIndex?: number
      tabBarModuleName?: string
      sizeIndeterminate?: boolean
    }
  }
}

export interface Drawer extends Layout {
  drawer: {
    children: [BuildInLayout | Layout, BuildInLayout | Layout]
    options?: {
      maxDrawerWidth?: number
      minDrawerMargin?: number
      menuInteractive?: boolean
    }
  }
}

export type BuildInLayout = Screen | Stack | Tabs | Drawer

export interface Layout {
  [index: string]: {}
}

export type RouteMode = 'modal' | 'present' | 'push'
export type LayoutMode = 'modal' | 'present' | 'normal'

export interface Route {
  sceneId: string
  moduleName: string
  mode: LayoutMode
  presentingId: string | null
  requestCode: number
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

export interface RouteData {
  moduleName: string
  regexp?: RegExp
  path?: string
  dependency?: string
  mode: RouteMode
}

export interface RouteInfo {
  moduleName: string
  mode: RouteMode
  dependencies: string[]
  props: object
  options: object
}

export interface RouteHandler {
  /**
   * @param graph - current RouteGraph to process
   * @param target - route may add to the graph
   * @returns [boolean, RouteGraph] - if the route is handled, return true and  childGraph for next Handler to process, [false, graph] otherwise
   */
  process: (graph: RouteGraph, target: RouteInfo) => Promise<[boolean, RouteGraph | null]>
}

export type RouteInterceptor = (path: string) => boolean | Promise<boolean>
