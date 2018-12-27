//
//  HBDEventEmitter.m
//  NavigationHybrid
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
NSString * const ON_DIALOG_BACK_PRESSED = @"ON_DIALOG_BACK_PRESSED";
NSString * const ON_COMPONENT_MOUNT = @"ON_COMPONENT_MOUNT";

NSString * const EVENT_SWITCH_TAB = @"EVENT_SWITCH_TAB";
NSString * const EVENT_NAVIGATION = @"EVENT_NAVIGATION";
NSString * const EVENT_SET_ROOT_COMPLETED = @"EVENT_SET_ROOT_COMPLETED";

NSString * const KEY_REQUEST_CODE = @"request_code";
NSString * const KEY_RESULT_CODE = @"result_code";
NSString * const KEY_RESULT_DATA = @"data";
NSString * const KEY_SCENE_ID = @"scene_id";
NSString * const KEY_MODULE_NAME = @"module_name";
NSString * const KEY_INDEX = @"index";
NSString * const KEY_FROM = @"from";
NSString * const KEY_ACTION = @"action";
NSString * const KEY_ON = @"on";

@implementation HBDEventEmitter


RCT_EXPORT_MODULE(HBDEventEmitter);

- (NSArray<NSString *> *)supportedEvents {
    return @[EVENT_NAVIGATION, EVENT_SWITCH_TAB, EVENT_SET_ROOT_COMPLETED];
}

- (NSDictionary<NSString *, NSString *> *)constantsToExport {
    return @{
             @"EVENT_NAVIGATION": EVENT_NAVIGATION,
             @"EVENT_SWITCH_TAB": EVENT_SWITCH_TAB,
             @"EVENT_SET_ROOT_COMPLETED": EVENT_SET_ROOT_COMPLETED,
             @"ON_COMPONENT_RESULT": ON_COMPONENT_RESULT,
             @"ON_BAR_BUTTON_ITEM_CLICK": ON_BAR_BUTTON_ITEM_CLICK,
             @"ON_COMPONENT_APPEAR": ON_COMPONENT_APPEAR,
             @"ON_COMPONENT_DISAPPEAR": ON_COMPONENT_DISAPPEAR,
             @"ON_DIALOG_BACK_PRESSED": ON_DIALOG_BACK_PRESSED,
             @"ON_COMPONENT_MOUNT": ON_COMPONENT_MOUNT,
             @"KEY_REQUEST_CODE": KEY_REQUEST_CODE,
             @"KEY_RESULT_CODE": KEY_RESULT_CODE,
             @"KEY_RESULT_DATA": KEY_RESULT_DATA,
             @"KEY_SCENE_ID": KEY_SCENE_ID,
             @"KEY_MODULE_NAME": KEY_MODULE_NAME,
             @"KEY_INDEX": KEY_INDEX,
             @"KEY_FROM": KEY_FROM,
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
    RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"HBDEventEmitter"];
    [emitter sendEventWithName:eventName body:data];
}

@end
