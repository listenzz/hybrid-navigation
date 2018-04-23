/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import { StyleSheet, StatusBar, Platform } from 'react-native';
import { ifIphoneX } from 'react-native-iphone-x-helper';
import { Navigation } from 'react-native-navigation-hybrid';

function ifLollipop(obj1 = {}, obj2 = {}) {
  return Platform.Version > 20 ? obj1 : obj2;
}

export default StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    ...Platform.select({
      ios: {
        ...ifIphoneX(
          {
            paddingTop: 16 + 88,
          },
          {
            paddingTop: 16 + 64,
          }
        ),
      },
      android: {
        ...ifLollipop(
          {
            paddingTop: 16 + StatusBar.currentHeight + Navigation.toolbarHeight,
          },
          {
            paddingTop: 16 + Navigation.toolbarHeight,
          }
        ),
      },
    }),
  },

  safeArea: {
    flex: 1,
  },

  button: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 40,
  },

  buttonText: {
    backgroundColor: 'transparent',
    color: 'rgb(34,88,220)',
  },

  buttonTextDisable: {
    backgroundColor: 'transparent',
    color: '#d1d1d1',
  },

  modalContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0, 0.5)',
  },

  modalContent: {
    backgroundColor: 'white',
    padding: 22,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 4,
    width: 320,
    borderColor: 'rgba(0, 0, 0, 0.3)',
  },

  modalButton: {
    backgroundColor: 'lightblue',
    padding: 12,
    margin: 16,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 4,
    borderColor: 'rgba(0, 0, 0, 0.1)',
  },

  result: {
    backgroundColor: 'transparent',
    textAlign: 'center',
    marginTop: 8,
    color: '#333333',
    fontSize: 13,
  },

  input: {
    height: 40,
    marginTop: 170,
    marginLeft: 32,
    marginRight: 32,
    marginBottom: 16,
    paddingLeft: 8,
    paddingRight: 8,
    borderColor: '#cccccc',
    borderWidth: 1,
  },

  welcome: {
    backgroundColor: 'transparent',
    fontSize: 17,
    textAlign: 'center',
    margin: 8,
  },

  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
