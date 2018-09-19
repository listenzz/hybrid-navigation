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

function addEvent(event) {
  events.push(event);
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
  addEvent,
  clear,
};
