import Event from '../Event';
import NavigationModule from '../NavigationModule';
import { BuildInLayout, Layout } from '../Route';

export default class LayoutCommandHandler {
  private willSetRoot = () => {};
  private didSetRoot = () => {};

  constructor() {}

  handleRootLayoutChange() {
    Event.listenWillSetRoot(() => {
      this.willSetRoot();
    });

    Event.listenDidSetRoot(() => {
      this.didSetRoot();
    });
  }

  setRoot(layout: BuildInLayout | Layout, sticky = false) {
    return NavigationModule.setRoot(layout, sticky);
  }

  setRootLayoutUpdateListener(willSetRoot = () => {}, didSetRoot = () => {}) {
    this.willSetRoot = willSetRoot;
    this.didSetRoot = didSetRoot;
  }
}
