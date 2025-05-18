import { Visibility } from '../Route';
import Event from '../Event';

export type VisibilityEventListener = (visibility: Visibility) => void
export type GlobalVisibilityEventListener = (sceneId: string, visibility: Visibility) => void

export default class VisibilityEventHandler {
  private listeners: Record<string, VisibilityEventListener[]> = {};
  private globalListeners: GlobalVisibilityEventListener[] = [];

  constructor() {}

  handleComponentVisibility() {
    Event.listenComponentVisibility((sceneId: string, visibility: Visibility) => {
      const listeners = this.listeners[sceneId];
      if (listeners) {
        listeners.forEach(listener => listener(visibility));
      }

      this.globalListeners.forEach(listener => listener(sceneId, visibility));
    });
  }

  addGlobalVisibilityEventListener(listener: GlobalVisibilityEventListener) {
    this.globalListeners.push(listener);
  }

  removeGlobalVisibilityEventListener(listener: GlobalVisibilityEventListener) {
    this.globalListeners = this.globalListeners.filter(l => l !== listener);
  }

  addVisibilityEventListener(sceneId: string, listener: VisibilityEventListener) {
    if (!this.listeners[sceneId]) {
      this.listeners[sceneId] = [];
    }
    this.listeners[sceneId].push(listener);
  }

  removeVisibilityEventListener(sceneId: string, listener: VisibilityEventListener) {
    if (this.listeners[sceneId]) {
      this.listeners[sceneId] = this.listeners[sceneId].filter(l => l !== listener);
    }
  }
}
