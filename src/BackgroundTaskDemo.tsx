import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import Navigation, { Navigator, statusBarHeight, withNavigationItem } from 'hybrid-navigation';
import styles from './Styles';
import BackgroundTask, { EventEmitter } from './BackgroundTask';

const { BACKGROUND_TASK_EVENT } = BackgroundTask.getConstants();

EventEmitter.addListener(BACKGROUND_TASK_EVENT, async () => {
  console.log('------------------------BACKGROUND_TASK_EVENT');
  const { sceneId } = await Navigation.currentRoute();
  Navigator.of(sceneId).redirectTo('Navigation');
});

export default withNavigationItem({
  titleItem: {
    title: 'BackgroundTask',
  },
})(BackgroundTaskDemo);

function BackgroundTaskDemo() {
  function scheduleTask() {
    BackgroundTask.scheduleTask();
  }

  return (
    <View style={[styles.container, { paddingTop: statusBarHeight() }]}>
      <TouchableOpacity onPress={scheduleTask} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}> scheduleTask </Text>
      </TouchableOpacity>
    </View>
  );
}
