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
    return @{ @"RESULT_OK": @(-1),
              @"RESULT_CANCEL": @(0)
              };
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"ON_COMPONENT_RESULT",
             @"ON_BAR_BUTTON_ITEM_CLICK",
             @"ON_COMPONENT_APPEAR",
             @"ON_COMPONENT_DISAPPEAR",
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

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout) {
    UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
    if (vc) {
        [[HBDReactBridgeManager sharedInstance] setRootViewController:vc];
    }
}

RCT_EXPORT_METHOD(push:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav;
    if (vc.drawerController) {
        nav = vc.drawerController.navigationController;
    } else  {
        nav = vc.navigationController;
    }
    
    if (nav) {
        HBDViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        target.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
        [nav pushViewController:target animated:animated];
    }
}

RCT_EXPORT_METHOD(pop:(NSString *)sceneId animated:(BOOL) animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        NSArray *children = vc.navigationController.childViewControllers;
        NSUInteger index = [children indexOfObject:vc];
        if (index > 0) {
            HBDViewController *target = children[index -1];
            [target didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:0];
        }
        [vc.navigationController popViewControllerAnimated:animated];
    }
}

RCT_EXPORT_METHOD(popTo:(NSString *)sceneId targetId:(NSString *)targetId animated:(BOOL) animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        NSArray *children = vc.navigationController.childViewControllers;
        HBDViewController *target;
        NSUInteger count = children.count;
        for (NSUInteger i = 0; i < count; i ++) {
            HBDViewController *vc = [children objectAtIndex:i];
            if ([vc.sceneId isEqualToString:targetId]) {
                target = vc;
                break;
            }
        }
        
        if (target) {
            if (vc != target) {
               [target didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:0];
            }
            [vc.navigationController popToViewController:target animated:animated];
        }
    }
}

RCT_EXPORT_METHOD(popToRoot:(NSString *)sceneId animated:(BOOL) animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        NSArray *children = vc.navigationController.childViewControllers;
        HBDViewController *root = [children objectAtIndex:0];
        if (vc != root) {
           [root didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:0];
        }
        [vc.navigationController popToRootViewControllerAnimated:animated];
    }
}

RCT_EXPORT_METHOD(isRoot:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        NSArray *children = vc.navigationController.childViewControllers;
        if (children.count > 0) {
            HBDReactViewController *vc = children[0];
            if ([vc.sceneId isEqualToString:sceneId]) {
                resolve(@YES);
            } else {
                resolve(@NO);
            }
        }
    }
}

RCT_EXPORT_METHOD(replace:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        HBDViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        if (nav.childViewControllers.count > 1) {
            [nav popViewControllerAnimated:NO];
            target.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            [nav pushViewController:target animated:NO];
        } else {
            [nav setViewControllers:@[ target ] animated:NO];
        }
    }
}

RCT_EXPORT_METHOD(replaceToRoot:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        HBDViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        [vc.navigationController setViewControllers:@[target] animated:NO];
    }
}

RCT_EXPORT_METHOD(present:(NSString *)sceneId moduleName:(NSString *)moduleName requestCode:(NSInteger)requestCode props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDViewController *vc = [self controllerForSceneId:sceneId];
    if (vc) {
        HBDViewController *root = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        HBDNavigationController *presented = [[HBDNavigationController alloc] initWithRootViewController:root];
        
        [presented setRequestCode:requestCode];
        [vc presentViewController:presented animated:animated completion:^{
            
        }];
    }
}

RCT_EXPORT_METHOD(setResult:(NSString *)sceneId resultCode:(NSInteger)resultCode data:(NSDictionary *)data) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(dismiss:(NSString *)sceneId animated:(BOOL)animated) {
    HBDViewController *vc = [self controllerForSceneId:sceneId];
    if (vc) {
        UIViewController *presenting = vc.presentingViewController;
        if (presenting) {
            [presenting didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:vc.requestCode];
        }
        
        [presenting dismissViewControllerAnimated:animated completion:^{
            
        }];
    }
}

RCT_EXPORT_METHOD(switchToTab:(NSString *)sceneId index:(NSInteger)index) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UITabBarController *tabBarController = vc.tabBarController;
    if (tabBarController) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        tabBarController.selectedIndex = index;
    }
}

RCT_EXPORT_METHOD(setTabBadge:(NSString *)sceneId index:(NSInteger)index text:(NSString *)text) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UITabBarController *tabBarController = vc.tabBarController;
    if (tabBarController) {
        UIViewController *vc = tabBarController.viewControllers[index];
        vc.tabBarItem.badgeValue = text;
    }
}

RCT_EXPORT_METHOD(toggleMenu:(NSString *)sceneId) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        [drawer toggleMenu];
    }
}

RCT_EXPORT_METHOD(openMenu:(NSString *)sceneId) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        [drawer openMenu];
    }
}

RCT_EXPORT_METHOD(closeMenu:(NSString *)sceneId) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        [drawer closeMenu];
    }
}

RCT_EXPORT_METHOD(setMenuInteractive:(NSString *)sceneId enabled:(BOOL)enabled) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        drawer.interactive = enabled;
    }
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    return [self controllerForSceneId:sceneId atController:controller];
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId atController:(UIViewController *)controller {
    HBDViewController *target;
    if ([controller isKindOfClass:[HBDViewController class]]) {
        HBDViewController *vc = (HBDViewController *)controller;
        if ([vc.sceneId isEqualToString:sceneId]) {
            target = vc;
        }
    }
    
    if (!target) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            target = [self controllerForSceneId:sceneId atController:presentedController];
        }
    }
    
    if (!target && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            target = [self controllerForSceneId:sceneId atController:child];
            if (target) {
                break;
            }
        }
    }
    return target;
}

@end
