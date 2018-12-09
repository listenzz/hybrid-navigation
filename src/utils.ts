import { EventEmitter } from './NavigationModule';
import { Navigator } from './Navigator';
import store from './store';

let actionIdGenerator = 0;

export interface BindOptions {
  inLayout?: boolean;
  sceneId?: string | undefined;
  navigatorFactory?: (sceneId: string) => Navigator;
}

function bindBarButtonItemClickEvent(item = {}, options: BindOptions = { inLayout: false }): void {
  if (options.inLayout) {
    removeBarButtonItemClickEventInLayout();
  }
  return JSON.parse(
    JSON.stringify(item, (key, value) => {
      if (key === 'action' && typeof value === 'function') {
        const action = 'ON_BAR_BUTTON_ITEM_CLICK_' + actionIdGenerator++;

        let event = EventEmitter.addListener(
          'ON_BAR_BUTTON_ITEM_CLICK',
          event => {
            if (event.action === action) {
              let navigator = store.getNavigator(event.sceneId);
              if (!navigator && options.inLayout && options.navigatorFactory) {
                navigator = options.navigatorFactory(event.sceneId);
              }
              navigator && value(navigator);
            }
          },
          {}
        );

        if (options.inLayout) {
          event.context.inLayout = true;
        }
        event.context.sceneId = options.sceneId;

        store.addBarButtonItemClickEvent(event);

        return action;
      }
      return value;
    })
  );
}

function removeBarButtonItemClickEventInLayout(): void {
  store
    .filterBarButtonItemClickEvent(event => !!event.context.inLayout)
    .forEach(event => {
      store.removeBarButtonItemClickEvent(event);
    });
}

function removeBarButtonItemClickEvent(sceneId: string): void {
  store
    .filterBarButtonItemClickEvent(
      event => event.context.sceneId && event.context.sceneId === sceneId
    )
    .forEach(event => {
      store.removeBarButtonItemClickEvent(event);
    });
}

export { bindBarButtonItemClickEvent, removeBarButtonItemClickEvent };
