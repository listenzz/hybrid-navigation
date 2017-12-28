import { ReactRegistry, Garden} from 'react-native-navigation-hybrid'; 
import { Image } from 'react-native'

import App from './App';
import ReactNavigation from './src/ReactNavigation';
import ReactResult from './src/ReactResult';

Garden.setStyle({
		topBarStyle: 'dark-content',
		 topBarBackgroundColor: '#3F51B5',
		// topBarTintColor: '#0000ff',
		backIcon: Image.resolveAssetSource(require('./src/ic_settings.png')),
		shadowImage: {
			color: '#dddddd',
		 	//image: Image.resolveAssetSource(require('./src/divider.png'))
		},
		// hideBackTitle: true,
		elevation: 2,
});

ReactRegistry.startRegisterComponent();

ReactRegistry.registerComponent('Navigator', () => App);
ReactRegistry.registerComponent('ReactNavigation', () => ReactNavigation);
ReactRegistry.registerComponent('Navigation', () => ReactNavigation);
ReactRegistry.registerComponent('ReactResult', () => ReactResult)

ReactRegistry.endRegisterComponent();