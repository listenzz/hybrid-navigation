import { AppRegistry, DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';
import React, { Component } from 'react';
import Navigator from './Navigator';
import NavigationModule from './NavigationModule';
import Garden from './Garden';

const EventEmitter = Platform.select({
  ios: new NativeEventEmitter(NavigationModule),
  android: DeviceEventEmitter,
});

let componentWrapperFunc;

export default ReactRegistry = {

    startRegisterComponent(componentWrapper) {
      console.info('begin register react component');
      componentWrapperFunc = componentWrapper;
      NavigationModule.startRegisterReactComponent();
    },

    endRegisterComponent() {
      NavigationModule.endRegisterReactComponent();
      console.info('end register react component');
    },

    registerComponent(appKey, componentProvider) {
      
      const RealComponent = componentProvider();

      class Screen extends Component {
        constructor(props){
          super(props);
          this.navigator = new Navigator(props.sceneId);
          this.garden = new Garden(props.sceneId);
          this.events = [];
        }

        handleBarButtonItemClick() {
          let event = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', (event) => {
            if(this.props.sceneId === event.sceneId) {
              if(this.refs.onlychild.onBarButtonItemClick) {
                this.refs.onlychild.onBarButtonItemClick(event.action);
              } else {
                console.warn(RealComponent.name + " 似乎未实现 onBarButtonItemClick");
              }
            }
          });    
          this.events.push(event);
        }

        handleComponentResultEvent() {
          let event = EventEmitter.addListener('ON_COMPONENT_RESULT', (event) => {                             
            if(this.props.sceneId === event.sceneId) {
              if(this.refs.onlychild.onComponentResult){
                this.refs.onlychild.onComponentResult(event.requestCode, event.resultCode, event.data);
              } else {
                // console.warn(RealComponent.name + " 似乎未实现 onComponentResult");
              }
            } 
          });
          this.events.push(event);
        }

        componentWillMount() {
          console.debug('componentWillMount   = ' + this.props.sceneId );
          this.handleComponentResultEvent();
          this.handleBarButtonItemClick();
        }

        componentDidMount() {
          console.debug('componentDidMount    = ' + this.props.sceneId);
          this.navigator.signalFirstRenderComplete();
        }

        componentWillUnmount() {
          console.debug('componentWillUnmount = ' + this.props.sceneId);
          this.events.forEach((event) => {
            event.remove();
          })
        }

        render() {
          return(
            <RealComponent ref='onlychild' {...this.props} navigator={this.navigator} garden={this.garden}/>
          )
        }
      }

      let RootComponent;
      if (componentWrapperFunc) {
        RootComponent = componentWrapperFunc(() => Screen);
      } else {
        RootComponent = Screen;
      }

      AppRegistry.registerComponent(appKey, () => RootComponent);
  
      // build static options
      let options = {};
      if (RealComponent.navigationItem) {
        options = RealComponent.navigationItem;
      }

      console.debug('register component:' + appKey + " options:" + JSON.stringify(options));
      NavigationModule.registerReactComponent(appKey, options);
    },

}