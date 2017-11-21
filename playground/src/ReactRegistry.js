import { AppRegistry } from 'react-native';
import React, { Component } from 'react';
import Navigator from './Navigator';
import NavigationModule from './NavigationModule';

export default ReactRegistry = {

    startRegisterComponent() {
        NavigationModule.startRegisterReactComponent();
    },

    endRegisterComponent() {
        NavigationModule.endRegisterReactComponent();
    
    },

    registerComponent(appKey, componentProvider) {
        const RealComponent = componentProvider();
        console.info(RealComponent);

        class Screen extends Component {
            constructor(props){
                super(props);
                this.navigator = new Navigator(props.navId, props.sceneId);
            }

            render() {
                return(<RealComponent {...this.props} navigator={this.navigator} />)
            }
        }

        AppRegistry.registerComponent(appKey, () => Screen );
        NavigationModule.registerReactComponent(appKey);
    },

    clearReactComponents() {
  
    }
}