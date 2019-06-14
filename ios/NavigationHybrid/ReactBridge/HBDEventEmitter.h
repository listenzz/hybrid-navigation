//
//  HBDEventEmitter.h
//  NavigationHybrid
//
//  Created by Listen on 2018/12/27.
//  Copyright © 2018 Listen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ON_COMPONENT_RESULT;
extern NSString * const ON_BAR_BUTTON_ITEM_CLICK;
extern NSString * const ON_COMPONENT_APPEAR;
extern NSString * const ON_COMPONENT_DISAPPEAR;
extern NSString * const ON_DIALOG_BACK_PRESSED;
extern NSString * const ON_COMPONENT_MOUNT;
extern NSString * const EVENT_SWITCH_TAB;
extern NSString * const EVENT_NAVIGATION;
extern NSString * const EVENT_SET_ROOT_COMPLETED;
extern NSString * const KEY_REQUEST_CODE;
extern NSString * const KEY_RESULT_CODE;
extern NSString * const KEY_RESULT_DATA;
extern NSString * const KEY_SCENE_ID;
extern NSString * const KEY_MODULE_NAME;
extern NSString * const KEY_INDEX;
extern NSString * const KEY_ACTION;
extern NSString * const KEY_ON;

@interface HBDEventEmitter : RCTEventEmitter <RCTBridgeModule>

+ (void)sendEvent:(NSString *)eventName data:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
