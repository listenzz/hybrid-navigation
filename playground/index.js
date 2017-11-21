import { AppRegistry } from 'react-native';
import App from './App';
import ReactNavigation from './src/ReactNavigation'

AppRegistry.registerComponent('Navigator', () => App);
AppRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
AppRegistry.registerComponent('Navigation', () => ReactNavigation);
