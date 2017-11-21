import { AppRegistry } from 'react-native';
import  ReactRegistry from './src/ReactRegistry'; 

import App from './App';
import ReactNavigation from './src/ReactNavigation'

ReactRegistry.startRegisterComponent();

ReactRegistry.registerComponent('Navigator', () => App);
ReactRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
ReactRegistry.registerComponent('Navigation', () => ReactNavigation);

ReactRegistry.endRegisterComponent();