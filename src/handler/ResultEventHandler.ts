import Event from '../Event'
import NavigationModule from '../NavigationModule'
interface IndexType {
  [index: string]: any
}

export type ResultType = IndexType | null
export type ResultEventListener<T extends ResultType> = (resultCode: number, data: T) => void

const { RESULT_CANCEL } = NavigationModule.getConstants()
export default class ResultEventHandler {
  private listeners: Record<string, Record<number, ResultEventListener<any>>> = {}

  constructor() {}

  handleComponentResult() {
    Event.listenComponentResult(
      (sceneId: string, requestCode: number, resultCode: number, data: any) => {
        const listener = this.listeners[sceneId]?.[requestCode]
        if (listener) {
          delete this.listeners[sceneId][requestCode]
          listener(resultCode, data)
        }
      },
    )
  }

  private addResultEventListener(
    sceneId: string,
    requestCode: number,
    listener: ResultEventListener<any>,
  ) {
    if (!this.listeners[sceneId]) {
      this.listeners[sceneId] = {}
    }
    const previousListener = this.listeners[sceneId][requestCode]
    if (previousListener) {
      previousListener(RESULT_CANCEL, null)
    }
    this.listeners[sceneId][requestCode] = listener
  }

  private removeResultEventListener(sceneId: string, requestCode: number) {
    if (this.listeners[sceneId]) {
      delete this.listeners[sceneId][requestCode]
    }
  }

  invalidateResultEventListener(sceneId: string) {
    const listeners = this.listeners[sceneId]
    if (listeners) {
      Object.values(listeners).forEach(listener => listener(RESULT_CANCEL, null))
    }

    delete this.listeners[sceneId]
  }

  waitResult<T extends ResultType>(sceneId: string, requestCode: number): Promise<[number, T]> {
    return new Promise<[number, T]>(resolve => {
      const listener = (resultCode: number, data: T) => {
        this.removeResultEventListener(sceneId, requestCode)
        resolve([resultCode, data])
      }
      this.addResultEventListener(sceneId, requestCode, listener)
    })
  }
}
