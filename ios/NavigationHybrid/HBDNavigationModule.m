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

RCT_EXPORT_METHOD(push:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = [self navigationControllerForController:vc];
    
    if (nav) {
        HBDViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        target.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
        [nav pushViewController:target animated:animated];
    }
}

RCT_EXPORT_METHOD(pop:(NSString *)sceneId animated:(BOOL) animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (nav) {
        NSArray *children = nav.childViewControllers;
        NSUInteger index = [children indexOfObject:vc];
        if (index > 0) {
            HBDViewController *target = children[index -1];
            [target didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:0];
        }
        [nav popViewControllerAnimated:animated];
    }
}

RCT_EXPORT_METHOD(popTo:(NSString *)sceneId targetId:(NSString *)targetId animated:(BOOL) animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (nav) {
        NSArray *children = nav.childViewControllers;
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
            [nav popToViewController:target animated:animated];
        }
    }
}

RCT_EXPORT_METHOD(popToRoot:(NSString *)sceneId animated:(BOOL) animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (nav) {
        NSArray *children = nav.childViewControllers;
        HBDViewController *root = [children objectAtIndex:0];
        if (vc != root) {
           [root didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:0];
        }
        [nav popToRootViewControllerAnimated:animated];
    }
}

RCT_EXPORT_METHOD(isRoot:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (nav) {
        NSArray *children = nav.childViewControllers;
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
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (nav) {
        HBDViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        [nav replaceViewController:target animated:YES];
    }
}

RCT_EXPORT_METHOD(replaceToRoot:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (nav) {
        HBDViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
        [nav replaceToRootViewController:target animated:YES];
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

- (UINavigationController *)navigationControllerForController:(UIViewController *)controller {
    UINavigationController *nav = controller.navigationController;;
    if (!nav && controller.drawerController) {
        HBDDrawerController *drawer = controller.drawerController;
        if ([drawer.contentController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBar = (UITabBarController *)drawer.contentController;
            if ([tabBar.selectedViewController isKindOfClass:[UINavigationController class]]) {
                nav = tabBar.selectedViewController;
            }
        } else if ([drawer.contentController isKindOfClass:[UINavigationController class]]){
            nav = (UINavigationController *)drawer.contentController;
        } else {
            nav = drawer.navigationController;
        }
    }
    return nav;
}

- (HBDViewController *)currentControllerInController:(UIViewController *)controller {
    if ([controller isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)controller;
        if (drawer.isMenuOpened) {
            return [self currentControllerInController:drawer.menuController];
        } else {
            return [self currentControllerInController:drawer.contentController];
        }
    } else if ([controller isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabs = (HBDTabBarController *)controller;
        return [self currentControllerInController:tabs.selectedViewController];
    } else if ([controller isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *stack = (HBDNavigationController *)controller;
        return [self currentControllerInController:stack.topViewController];
    } else if ([controller isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *)controller;
    }
    return nil;
}

RCT_EXPORT_METHOD(routeGraph:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    NSMutableArray *container = [[NSMutableArray alloc] init];
    while (controller != nil) {
        [self routeGraphWithController:controller container:container];
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            controller = presentedController;
        } else {
            controller = nil;
        }
    }
    resolve(container);
}

- (void)routeGraphWithController:(UIViewController *)controller container:(NSMutableArray *)container {
    if ([controller isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)controller;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        [self routeGraphWithController:drawer.contentController container:children];
        [self routeGraphWithController:drawer.menuController container:children];
        [container addObject:@{ @"type": @"drawer", @"drawer": children }];
    } else if ([controller isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabs = (HBDTabBarController *)controller;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < tabs.childViewControllers.count; i++) {
            UIViewController *child = tabs.childViewControllers[i];
            [self routeGraphWithController:child container:children];
        }
        [container addObject:@{ @"type": @"tabs", @"tabs": children, @"selectedIndex": @(tabs.selectedIndex) }];
    } else if ([controller isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *stack = (HBDNavigationController *)controller;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < stack.childViewControllers.count; i++) {
            UIViewController *child = stack.childViewControllers[i];
            [self routeGraphWithController:child container:children];
        }
        [container addObject:@{ @"type": @"stack", @"stack": children }];
    } else if ([controller isKindOfClass:[HBDViewController class]]) {
        HBDViewController *screen = (HBDViewController *)controller;
        [container addObject:@{
                               @"type": @"screen",
                               @"screen": @{ @"moduleName": screen.moduleName, @"sceneId": screen.sceneId}
                               }];
    } else {
        NSLog(@"warning: controller do not add to route graph!!");
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
