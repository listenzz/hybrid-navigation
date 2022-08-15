import Event from '../Event'

type BarButtonClickEventListener = (sceneId: string, value: Function) => void

export default class BarButtonEventHandler {
  private actions: Record<string, Function> = {}
  private keyPairs: Record<string, string[]> = {}
  private actionIdGenerator = 0

  bindBarButtonClickEvent(sceneId: string, item: object | null | undefined): object | null {
    if (item === null || item === undefined) {
      return null
    }

    return JSON.parse(
      JSON.stringify(item, (key, value) => {
        if (key !== 'action' || typeof value !== 'function') {
          return value
        }

        const actionKey = 'ON_BAR_BUTTON_ITEM_CLICK_' + this.actionIdGenerator++

        if (!this.keyPairs[sceneId]) {
          this.keyPairs[sceneId] = []
        }
        this.keyPairs[sceneId].push(actionKey)
        this.actions[actionKey] = value

        return actionKey
      }),
    )
  }

  unbindBarButtonClickEvent(sceneId: string): void {
    const keys = this.keyPairs[sceneId]
    delete this.keyPairs[sceneId]
    if (keys) {
      keys.forEach(key => delete this.actions[key])
    }
  }

  setBarButtonClickEventListener(handler: BarButtonClickEventListener) {
    Event.listenBarButtonItemClick((sceneId: string, action: string) => {
      const listeners = this.actions
      if (listeners[action]) {
        handler(sceneId, listeners[action])
      }
    })
  }
}
