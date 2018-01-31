import { AppRegistry, DeviceEventEmitter, NativeEventEmitter, Platform } from 'react-native';
import React, { Component } from 'react';
import Navigator from './Navigator';
import NavigationModule from './NavigationModule';
import Garden from './Garden';

const EventEmitter = Platform.select({
  ios: new NativeEventEmitter(NavigationModule),
  android: DeviceEventEmitter,
});

export default ReactRegistry = {
  
    startRegisterComponent() {
      console.info('begin register react component');
      NavigationModule.startRegisterReactComponent();
    },

    endRegisterComponent() {
      NavigationModule.endRegisterReactComponent();
      console.info('end register react component');
    },

    registerComponent(appKey, componentProvider) {
      const RealComponent = componentProvider();
      function hookRealComponent(klass) {
        const Traits = function () {};
        Traits.prototype = klass.prototype;
        return function () {
          var instance = new Traits();
          klass.apply(instance, arguments);

          let events = [];
  
          const realComponentWillMount = instance.componentWillMount;
          instance.componentWillMount = function() {
            if (realComponentWillMount) {
              realComponentWillMount.apply(instance);
            }
            let event = EventEmitter.addListener('ON_COMPONENT_RESULT', function(event){                             
              if(instance.props.sceneId === event.sceneId) {
                if(instance.onComponentResult){
                  let data = event.data && JSON.stringify(event.data);
                  console.info('requestCode:' + event.requestCode + ' resultCode:' + event.resultCode + ' data:' + data);
                  instance.onComponentResult(event.requestCode, event.resultCode, event.data);
                } else {
                  // console.warn(RealComponent.name + " 似乎未实现 onComponentResult");
                }
              } 
            });
            events.push(event);

            evnet = EventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', function(event) {
              if(instance.props.sceneId === event.sceneId) {
                if(instance.onBarButtonItemClick) {
                  instance.onBarButtonItemClick(event.action);
                } else {
                  console.warn(RealComponent.name + " 似乎未实现 onBarButtonItemClick");
                }
              }
            });    

            events.push(event);
          }

          // 绑定监听事件
          const realComponentDidMount = instance.componentDidMount;
          instance.componentDidMount = function() {
            if(realComponentDidMount) {
              realComponentDidMount.apply(instance);
            }
            instance.props.navigator.signalFirstRenderComplete();
          }

          // 解绑监听事件
          const realComponentWillUnmount = instance.componentWillUnmount;
          instance.componentWillUnmount = function() {
            if(realComponentWillUnmount) {
              realComponentWillUnmount.apply(instance);
            }
            events.forEach(function(event){
              event.remove();
            })
          }
          return instance;
        };
      }

      const ProxiedComponent =  hookRealComponent(RealComponent);
      class Screen extends Component {
        constructor(props){
          super(props);
          this.navigator = new Navigator(props.sceneId);
          this.garden = new Garden(props.sceneId);
        }

        componentWillMount() {
          console.log('componentWillMount   = ' + this.props.sceneId );
        }

        componentDidMount() {
          console.log('componentDidMount    = ' + this.props.sceneId);
        }

        componentWillUnmount() {
          console.log('componentWillUnmount = ' + this.props.sceneId);
        }

        render() {
          return(
            <ProxiedComponent{...this.props} navigator={this.navigator} garden={this.garden}/>
          )
        }
      }

      AppRegistry.registerComponent(appKey, () => Screen );

      // build static options
      let options = {};
      if (RealComponent.navigationItem) {
        options = RealComponent.navigationItem;
      }

      console.debug('register component:' + appKey + " options:" + JSON.stringify(options));
      NavigationModule.registerReactComponent(appKey, options);
    },

}