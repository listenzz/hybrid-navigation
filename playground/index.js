import { ReactRegistry, Garden, Navigator } from 'react-native-navigation-hybrid'; 
import { Image } from 'react-native'

import App from './App';
import ReactNavigation from './src/ReactNavigation';
import ReactResult from './src/ReactResult';
import CustomStyle from './src/CustomStyle';
import HideBackButton from './src/HideBackButton';
import HideTopBarShadow from './src/HideTopBarShadow';
import PassOptions from './src/PassOptions';
import Menu from './src/Menu';

Garden.setStyle({
		topBarStyle: 'dark-content',
		// topBarBackgroundColor: '#3F51B5',
		// topBarTintColor: '#0000ff',
		// backIcon: Image.resolveAssetSource(require('./src/ic_settings.png')),
		shadowImage: {
			color: '#dddddd',
		 	//image: Image.resolveAssetSource(require('./src/divider.png'))
		},
		// hideBackTitle: true,
		elevation: 1,
		// tabBarItemSelectedColor: '#FF0000',
		// tabBarBackgroundColor: '#00FF00',
});

ReactRegistry.startRegisterComponent();

ReactRegistry.registerComponent('Navigator', () => App);
ReactRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
ReactRegistry.registerComponent('Navigation', () => ReactNavigation);
ReactRegistry.registerComponent('ReactResult', () => ReactResult)
ReactRegistry.registerComponent('CustomStyle', () => CustomStyle)
ReactRegistry.registerComponent('HideBackButton', () => HideBackButton)
ReactRegistry.registerComponent('HideTopBarShadow', () => HideTopBarShadow)
ReactRegistry.registerComponent('PassOptions', () => PassOptions)
ReactRegistry.registerComponent('Menu', () => Menu);

ReactRegistry.endRegisterComponent();