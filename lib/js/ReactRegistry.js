import { AppRegistry, DeviceEventEmitter } from 'react-native';
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

        function hookRealComponent(klass) {
            const Traits = function () {};
            Traits.prototype = klass.prototype;
            return function () {
                var instance = new Traits();
                klass.apply(instance, arguments);

                let events = [];
                // 绑定监听事件
                const realComponentWillMount = instance.componentWillMount;
                instance.componentWillMount = function() {
                    if (realComponentWillMount) {
                        realComponentWillMount.apply(instance);
                    }

                    let event = DeviceEventEmitter.addListener('ON_COMPONENT_RESULT', function(event){                             
                        if(instance.props.sceneId === event.sceneId) {
                            if(instance.onComponentResult){
                                let data = event.data && JSON.stringify(event.data);
                                console.info('requestCode:' + event.requestCode + ' resultCode:' + event.resultCode + ' data:' + data);
                                instance.onComponentResult(event.requestCode, event.resultCode, event.data);
                            } else {
                                console.warn(RealComponent.name + " 似乎未实现 onComponentResult");
                            }
                        } 
                    });
                    events.push(event);

                    evnet = DeviceEventEmitter.addListener('ON_BAR_BUTTON_ITEM_CLICK', function(event) {
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

                const realComponentDidMount = instance.componentDidMount;
                instance.componentDidMount = function() {
                    if(realComponentDidMount) {
                        realComponentDidMount.apply(instance);
                    }

                }

                return instance;
            };
        }

        const ProxiedComponent =  hookRealComponent(RealComponent);
        class Screen extends Component {
            constructor(props){
                super(props);
                this.navigator = new Navigator(props.navId, props.sceneId);
            }

            componentDidMount() {
                this.navigator.signalFirstRenderComplete();
            }

            render() {
                return(<ProxiedComponent {...this.props} navigator={this.navigator} />)
            }
        }

        AppRegistry.registerComponent(appKey, () => Screen );

        // build static options
        let options = {};
        if (RealComponent.titleItem) {
            options.titleItem = RealComponent.titleItem;
        }

        if (RealComponent.rightBarButtonItem) {
            options.rightBarButtonItem = RealComponent.rightBarButtonItem;
        }

        console.debug('register component:' + appKey + " options:" + JSON.stringify(options));
        NavigationModule.registerReactComponent(appKey, options);
    },

}