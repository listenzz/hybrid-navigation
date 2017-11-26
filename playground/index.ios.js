import { AppRegistry } from 'react-native';
import  { ReactRegistry } from 'react-native-navigation-hybrid'; 

import App from './App';
import ReactNavigation from './src/ReactNavigation';
import ReactResult from './src/ReactResult';


ReactRegistry.startRegisterComponent();

ReactRegistry.registerComponent('Navigator', () => App);
ReactRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
ReactRegistry.registerComponent('Navigation', () => ReactNavigation);
ReactRegistry.registerComponent('ReactResult', () => ReactResult)

ReactRegistry.endRegisterComponent();