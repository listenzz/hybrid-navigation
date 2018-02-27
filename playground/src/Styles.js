/**
 * react-native-navigation-hybrid
 * https://github.com/listenzz/react-native-navigation-hybrid
 * @flow
 */

import { StyleSheet } from 'react-native';

export default StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    // backgroundColor: '#F5FCFF',
    paddingTop: 16,
  },
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 40,
  },
  buttonText: {
    color: 'rgb(34,88,220)',
  },

  buttonTextDisable: {
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
