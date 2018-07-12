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
#import "HBDNavigationController.h"
#import "UINavigationController+HBD.h"
#import "HBDTabBarController.h"
#import "HBDModalViewController.h"

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
             @"ON_COMPONENT_BACK",
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
    HBDReactViewController *vc =  (HBDReactViewController *)[self controllerForSceneId:sceneId];
    [vc signalFirstRenderComplete];
}

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout sticky:(BOOL)sticky) {
    UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
    if (vc) {
        [[HBDReactBridgeManager sharedInstance] setRootViewController:vc];
    }
}

RCT_EXPORT_METHOD(dispatch:(NSString *)sceneId action:(NSString *)action extras:(NSDictionary *)extras) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc) {
        [[HBDReactBridgeManager sharedInstance] handleNavigationWithViewController:vc action:action extras:extras];
    }
}

RCT_EXPORT_METHOD(isNavigationRoot:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
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
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(currentRoute:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    while (controller != nil) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            controller = presentedController;
        } else {
            break;
        }
    }
    
    HBDViewController *current = [self currentControllerInController:controller];
    if (current) {
        resolve(@{ @"moduleName": current.moduleName, @"sceneId": current.sceneId });
    } else {
        reject(@"404", @"not found!", [NSError errorWithDomain:@"NavigationModuleDomain" code:404 userInfo:nil]);
    }
}

- (HBDViewController *)currentControllerInController:(UIViewController *)controller {
    return [[HBDReactBridgeManager sharedInstance] primaryChildViewControllerInController:controller];
}

RCT_EXPORT_METHOD(routeGraph:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    NSMutableArray *container = [[NSMutableArray alloc] init];
    while (controller != nil) {
        [self routeGraphWithController:controller container:container];
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && !presentedController.isBeingDismissed) {
            controller = presentedController;
        } else {
            controller = nil;
        }
    }
    resolve(container);
}

- (void)routeGraphWithController:(UIViewController *)controller container:(NSMutableArray *)container {
    [[HBDReactBridgeManager sharedInstance] routeGraphWithController:controller container:container];
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    HBDViewController *vc = [self controllerForSceneId:sceneId inController:controller];
    return vc;
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId inController:(UIViewController *)controller {
    HBDViewController *target;
    
    if ([controller isKindOfClass:[HBDViewController class]]) {
        HBDViewController *vc = (HBDViewController *)controller;
        if ([vc.sceneId isEqualToString:sceneId]) {
            target = vc;
        }
    }
    
    if (!target && [controller isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)controller;
        target = [self controllerForSceneId:sceneId inController:modal.contentViewController];
    }
    
    if (!target) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            target = [self controllerForSceneId:sceneId inController:presentedController];
        }
    }
    
    if (!target && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            target = [self controllerForSceneId:sceneId inController:child];
            if (target) {
                break;
            }
        }
    }
    return target;
}

@end
