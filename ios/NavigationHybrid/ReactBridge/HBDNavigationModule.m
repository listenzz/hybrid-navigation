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
    UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    if ([vc isKindOfClass:[HBDReactViewController class]]) {
        [(HBDReactViewController *)vc signalFirstRenderComplete];
    }
}

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout sticky:(BOOL)sticky) {
    UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
    if (vc) {
        [HBDReactBridgeManager sharedInstance].hasRootLayout = YES;
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
        RCTLogWarn(@"View Hierarchy is not ready when you call Navigator#currentRoute. In order to avoid this warning, please use Navigator#setRootLayoutUpdateListener coordinately.");
        resolve(NSNull.null);
    }
}

RCT_EXPORT_METHOD(routeGraph:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSArray *root = [[HBDReactBridgeManager sharedInstance] routeGraph];
    if (root.count > 0) {
        resolve(root);
    } else {
        RCTLogWarn(@"View Hierarchy is not ready when you call Navigator#routeGraph. In order to avoid this warning, please use Navigator#setRootLayoutUpdateListener coordinately.");
        resolve(NSNull.null);
    }
}

@end
