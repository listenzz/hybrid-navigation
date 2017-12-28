/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import {
  StyleSheet,
} from 'react-native';

export default styles = StyleSheet.create({
    container: {
      flex: 1,
      justifyContent: 'flex-start',
      alignItems: 'stretch',
      // backgroundColor: '#F5FCFF',
      paddingTop: 56,
    },
    button: {
      alignItems: "center",
      justifyContent: "center",
      height: 40,
    },
    buttonText: {

    },

    modalContainer: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: 'rgba(0,0,0, 0.5)'
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

    buttonTextDisable: {
      color: '#d1d1d1'
    },

    result: {
      textAlign: 'center',
      color: '#333333',
      fontSize: 13,
    },
    input: {
      height: 40,
      marginLeft: 32,
      marginRight: 32,
      marginBottom: 16,
      paddingLeft: 8,
      paddingRight:8,
      borderColor: '#cccccc',
      borderWidth: 1,
    },
    welcome: {
      fontSize: 17,
      textAlign: 'center',
      margin: 16,
    },
    instructions: {
      textAlign: 'center',
      color: '#333333',
      marginBottom: 5,
    },
  });

