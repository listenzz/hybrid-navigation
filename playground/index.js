import { ReactRegistry, Garden, TOP_BAR_STYLE_LIGHT_CONTENT } from 'react-native-navigation-hybrid'; 
import { Image } from 'react-native'

import App from './App';
import ReactNavigation from './src/ReactNavigation';
import ReactResult from './src/ReactResult';

//Garden.setTopBarStyle(TOP_BAR_STYLE_LIGHT_CONTENT);
Garden.setTopBarBackgroundColor('#77889933')

ReactRegistry.startRegisterComponent();

ReactRegistry.registerComponent('Navigator', () => App);
ReactRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
//ReactRegistry.registerComponent('Navigation', () => ReactNavigation);
ReactRegistry.registerComponent('ReactResult', () => ReactResult)

ReactRegistry.endRegisterComponent();