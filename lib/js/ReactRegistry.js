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
                                instance.onComponentResult(event.requestCode, event.resultCode, event.data);
                            } else {
                                console.warn(RealComponent.name + " 似乎未实现 onComponentResult");
                            }
                        } 
                    });
                    events.push(event);
                    console.info("注册监听事件");
                }

                // 解绑监听事件
                const realComponentWillUnmount = instance.componentWillUnmount;
                instance.componentWillUnmount = function() {
                    if(realComponentWillUnmount) {
                        realComponentWillUnmount.apply(instance);
                    }
                    events.forEach(function(event){
                        event.remove();
                        console.info('移除监听事件');
                    })
                }

                // console.info(instance);
                return instance;
            };
        }

        const ProxiedComponent =  hookRealComponent(RealComponent);
        class Screen extends Component {
            constructor(props){
                super(props);
                this.navigator = new Navigator(props.navId, props.sceneId);
            }

            render() {
                return(<ProxiedComponent {...this.props} navigator={this.navigator} />)
            }
        }

        AppRegistry.registerComponent(appKey, () => Screen );
        NavigationModule.registerReactComponent(appKey);
    },

}