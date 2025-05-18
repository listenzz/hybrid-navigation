import React from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';
import Navigation, { withNavigationItem, NavigationProps } from 'hybrid-navigation';

import styles from './Styles';

export default withNavigationItem({
  statusBarColorAndroid: '#0000FF',
  titleItem: {
    title: 'StatusBar Color',
  },
})(StatusBarColor);

function StatusBarColor({ sceneId, navigator }: NavigationProps) {
  function red() {
    Navigation.updateOptions(sceneId, { statusBarColorAndroid: '#FF0000' });
  }

  function green() {
    Navigation.updateOptions(sceneId, { statusBarColorAndroid: '#00FF00' });
  }

  function blue() {
    Navigation.updateOptions(sceneId, { statusBarColorAndroid: '#0000FF' });
  }

  function statusBarColor() {
    navigator.push('StatusBarColor');
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>For Android only</Text>
      </View>

      <TouchableOpacity onPress={red} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>Red</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={blue} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>Blue</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={green} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>Green</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={statusBarColor} activeOpacity={0.2} style={styles.button}>
        <Text style={styles.buttonText}>StatucsBarColor</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}
