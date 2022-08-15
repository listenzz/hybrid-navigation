import Event from '../Event'
import NavigationModule from '../NavigationModule'
import { BuildInLayout, Layout } from '../Route'

export default class LayoutCommandHandler {
  private willSetRoot = () => {}
  private didSetRoot = () => {}

  private canInvokeWillSetRoot = true
  private tagGenerator = 0

  constructor() {}

  handleRootLayoutChange() {
    Event.listenWillSetRoot(() => {
      if (this.canInvokeWillSetRoot) {
        this.willSetRoot()
      }
    })

    Event.listenDidSetRoot(() => {
      this.didSetRoot()
      this.canInvokeWillSetRoot = true
    })
  }

  setRoot(layout: BuildInLayout | Layout, sticky = false) {
    this.willSetRoot()
    this.canInvokeWillSetRoot = false

    const flag = this.tagGenerator++
    NavigationModule.setRoot(layout, sticky, flag)

    return new Promise<void>(resolve => {
      const subscription = Event.listenDidSetRoot((tag: number) => {
        // FIXME: 此处恐有内存泄漏
        if (tag === flag) {
          subscription.remove()
          resolve()
        }
      })
    })
  }

  setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    this.willSetRoot = willSetRoot
    this.didSetRoot = didSetRoot
  }
}
