const navigators = new Map();

let events = [];

function addNavigator(sceneId, navigator) {
  navigators.set(sceneId, navigator);
}

function removeNavigator(sceneId) {
  navigators.delete(sceneId);
}

function getNavigator(sceneId) {
  return navigators.get(sceneId);
}

function addBarButtonItemClickEvent(event) {
  events.push(event);
}

function removeBarButtonItemClickEvent(event) {
  event.remove();
  events = events.filter(e => e !== event);
}

function filterBarButtonItemClickEvent(callback) {
  return events.filter(callback);
}

function clear() {
  navigators.clear();
  events.forEach(event => {
    event.remove();
  });
  events = [];
}

export default {
  addNavigator,
  removeNavigator,
  getNavigator,
  addBarButtonItemClickEvent,
  removeBarButtonItemClickEvent,
  filterBarButtonItemClickEvent,
  clear,
};
