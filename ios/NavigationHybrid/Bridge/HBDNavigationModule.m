//
//  HBDNavigatorModule.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/19.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDNavigationModule.h"
#import <React/RCTLog.h>
#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"

@interface HBDNavigationModule()

@end

@implementation HBDNavigationModule

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(NavigationHybrid)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{ @"RESULT_OK": @(ResultOK),
              @"RESULT_CANCEL": @(ResultCancel)
              };
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"ON_COMPONENT_RESULT",
             @"ON_BAR_BUTTON_ITEM_CLICK",
             @"ON_COMPONENT_APPEAR",
             @"ON_COMPONENT_DISAPPEAR",
             @"ON_DIALOG_BACK_PRESSED", // for Android
             ];
}

RCT_EXPORT_METHOD(startRegisterReactComponent) {
    [[HBDReactBridgeManager sharedInstance] startRegisterReactModule];
}

RCT_EXPORT_METHOD(endRegisterReactComponent) {
    [[HBDReactBridgeManager sharedInstance] endRegisterReactModule];
}

RCT_EXPORT_METHOD(registerReactComponent:(NSString *)appKey options:(NSDictionary *)options) {
    [[HBDReactBridgeManager sharedInstance] registerReactModule:appKey options:options];
}

RCT_EXPORT_METHOD(signalFirstRenderComplete:(NSString *)sceneId) {
    // NSLog(@"signalFirstRenderComplete sceneId:%@",sceneId);
    HBDReactViewController *vc =  (HBDReactViewController *)[[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    [vc signalFirstRenderComplete];
}

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout sticky:(BOOL)sticky) {
    UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
    if (vc) {
        [[HBDReactBridgeManager sharedInstance] setRootViewController:vc];
    }
}

RCT_EXPORT_METHOD(dispatch:(NSString *)sceneId action:(NSString *)action extras:(NSDictionary *)extras) {
    UIViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    if (vc) {
        [[HBDReactBridgeManager sharedInstance] handleNavigationWithViewController:vc action:action extras:extras];
    }
}

RCT_EXPORT_METHOD(isNavigationRoot:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        NSArray *children = nav.childViewControllers;
        if (children.count > 0) {
            HBDReactViewController *vc = children[0];
            if ([vc.sceneId isEqualToString:sceneId]) {
                resolve(@YES);
                return;
            }
        }
    }
    resolve(@NO);
}

RCT_EXPORT_METHOD(setResult:(NSString *)sceneId resultCode:(NSInteger)resultCode data:(NSDictionary *)data) {
    UIViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(currentRoute:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    HBDViewController *current = [[HBDReactBridgeManager sharedInstance] primaryViewController];
    if (current) {
        resolve(@{ @"moduleName": current.moduleName, @"sceneId": current.sceneId });
    } else {
        reject(@"1", @"UI 层级还没准备好", [NSError errorWithDomain:RCTErrorDomain code:1 userInfo:nil]);
    }
}

RCT_EXPORT_METHOD(routeGraph:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSArray *root = [[HBDReactBridgeManager sharedInstance] routeGraph];
    if (root.count > 0) {
        resolve(root);
    } else {
        reject(@"2", @"UI 层级还没准备好", [NSError errorWithDomain:RCTErrorDomain code:2 userInfo:nil]);
    }
}

@end
