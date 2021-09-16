//
//  HBDEventEmitter.m
//  HybridNavigation
//
//  Created by Listen on 2018/12/27.
//  Copyright © 2018 Listen. All rights reserved.
//

#import "HBDEventEmitter.h"
#import "HBDReactBridgeManager.h"

NSString * const ON_COMPONENT_RESULT = @"ON_COMPONENT_RESULT";
NSString * const ON_BAR_BUTTON_ITEM_CLICK = @"ON_BAR_BUTTON_ITEM_CLICK";
NSString * const ON_COMPONENT_APPEAR = @"ON_COMPONENT_APPEAR";
NSString * const ON_COMPONENT_DISAPPEAR = @"ON_COMPONENT_DISAPPEAR";

NSString * const EVENT_SWITCH_TAB = @"EVENT_SWITCH_TAB";
NSString * const EVENT_NAVIGATION = @"EVENT_NAVIGATION";
NSString * const EVENT_DID_SET_ROOT = @"EVENT_DID_SET_ROOT";
NSString * const EVENT_WILL_SET_ROOT = @"EVENT_WILL_SET_ROOT";

NSString * const KEY_REQUEST_CODE = @"request_code";
NSString * const KEY_RESULT_CODE = @"result_code";
NSString * const KEY_RESULT_DATA = @"data";
NSString * const KEY_SCENE_ID = @"scene_id";
NSString * const KEY_MODULE_NAME = @"module_name";
NSString * const KEY_INDEX = @"index";
NSString * const KEY_ACTION = @"action";
NSString * const KEY_ON = @"on";

@implementation HBDEventEmitter


RCT_EXPORT_MODULE(HBDEventEmitter);

- (NSArray<NSString *> *)supportedEvents {
    return @[EVENT_NAVIGATION, EVENT_SWITCH_TAB, EVENT_DID_SET_ROOT, EVENT_WILL_SET_ROOT];
}

- (NSDictionary<NSString *, NSString *> *)constantsToExport {
    return @{
             @"EVENT_NAVIGATION": EVENT_NAVIGATION,
             @"EVENT_SWITCH_TAB": EVENT_SWITCH_TAB,
             @"EVENT_DID_SET_ROOT": EVENT_DID_SET_ROOT,
             @"EVENT_WILL_SET_ROOT": EVENT_WILL_SET_ROOT,
             @"ON_COMPONENT_RESULT": ON_COMPONENT_RESULT,
             @"ON_BAR_BUTTON_ITEM_CLICK": ON_BAR_BUTTON_ITEM_CLICK,
             @"ON_COMPONENT_APPEAR": ON_COMPONENT_APPEAR,
             @"ON_COMPONENT_DISAPPEAR": ON_COMPONENT_DISAPPEAR,
             @"KEY_REQUEST_CODE": KEY_REQUEST_CODE,
             @"KEY_RESULT_CODE": KEY_RESULT_CODE,
             @"KEY_RESULT_DATA": KEY_RESULT_DATA,
             @"KEY_SCENE_ID": KEY_SCENE_ID,
             @"KEY_MODULE_NAME": KEY_MODULE_NAME,
             @"KEY_INDEX": KEY_INDEX,
             @"KEY_ACTION": KEY_ACTION,
             @"KEY_ON": KEY_ON,
             };
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

+ (void)sendEvent:(NSString *)eventName data:(NSDictionary *)data {
    HBDReactBridgeManager *manager = [HBDReactBridgeManager get];
    RCTBridge *bride = manager.bridge;
    if (bride.valid && manager.isReactModuleRegisterCompleted) {
        RCTEventEmitter *emitter = [bride moduleForName:@"HBDEventEmitter"];
        [emitter sendEventWithName:eventName body:data];
    }
}

@end
