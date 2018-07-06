import { StyleSheet } from 'react-native';

export default StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    paddingTop: 16,
  },

  transparent: {
    marginTop: 150,
    width: 200,
    height: 120,
    backgroundColor: 'rgba(0,0,0, 0.5)',
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center',
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
});
