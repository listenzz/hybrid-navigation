import { EventEmitter } from './NavigationModule';
import store from './store';
import Navigator from './Navigator';

let actionIdGenerator = 0;

function bindBarButtonItemClickEvent(item = {}, options = { inLayout: false, sceneId: undefined }) {
  if (options.inLayout) {
    removeBarButtonItemClickEventInLayout();
  }
  return JSON.parse(
    JSON.stringify(item, (key, value) => {
      if (key === 'action' && typeof value === 'function') {
        const action = 'ON_BAR_BUTTON_ITEM_CLICK_' + actionIdGenerator++;

        let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', event => {
          if (event.action === action) {
            let navigator = store.getNavigator(event.sceneId);
            if (!navigator && options.inLayout) {
              navigator = new Navigator(event.sceneId);
            }
            navigator && value(navigator);
          }
        });

        if (options.inLayout) {
          event.inLayout = true;
        }
        event.sceneId = options.sceneId;

        store.addBarButtonItemClickEvent(event);

        return action;
      }
      return value;
    })
  );
}

function removeBarButtonItemClickEventInLayout() {
  store.filterBarButtonItemClickEvent(event => !!event.inLayout).forEach(event => {
    store.removeBarButtonItemClickEvent(event);
  });
}

function removeBarButtonItemClickEvent(sceneId) {
  store
    .filterBarButtonItemClickEvent(event => event.sceneId && event.sceneId === sceneId)
    .forEach(event => {
      store.removeBarButtonItemClickEvent(event);
    });
}

export { bindBarButtonItemClickEvent, removeBarButtonItemClickEvent };
