//
//  HBDNavigatorModule.m
//
//  Created by Listen on 2017/11/19.
//

#import "HBDNavigatorModule.h"
#import <React/RCTLog.h>
#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"
#import "HBDNavigationController.h"

@interface HBDNavigatorModule()

@end

@implementation HBDNavigatorModule

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
             @"ON_BAR_BUTTON_ITEM_CLICK"
             ];
}

RCT_EXPORT_METHOD(startRegisterReactComponent) {
    [[HBDReactBridgeManager instance] startRegisterReactModule];
}

RCT_EXPORT_METHOD(endRegisterReactComponent) {
    [[HBDReactBridgeManager instance] endRegisterReactModule];
}

RCT_EXPORT_METHOD(registerReactComponent:(NSString *)appKey options:(NSDictionary *)options) {
    [[HBDReactBridgeManager instance] registerReactModule:appKey options:options];
}

RCT_EXPORT_METHOD(signalFirstRenderComplete:(NSString *)navId sceneId:(NSString *)sceneId) {
    NSLog(@"signalFirstRenderComplete navId:%@ sceneId:%@", navId, sceneId);
}

RCT_EXPORT_METHOD(push:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    UINavigationController *nav;
    if (vc.drawerController) {
        nav = vc.drawerController.navigationController;
    } else  {
        nav = vc.navigationController;
    }
    
    if (nav) {
        HBDViewController *target = [[HBDReactBridgeManager instance] controllerWithModuleName:moduleName props:props options:options];
        target.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
        [nav pushViewController:target animated:animated];
    }
}

RCT_EXPORT_METHOD(pop:(NSString *)navId sceneId:(NSString *)sceneId animated:(BOOL) animated) {
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

RCT_EXPORT_METHOD(popTo:(NSString *)navId sceneId:(NSString *)sceneId targetId:(NSString *)targetId animated:(BOOL) animated) {
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

RCT_EXPORT_METHOD(popToRoot:(NSString *)navId sceneId:(NSString *)sceneId animated:(BOOL) animated) {
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

RCT_EXPORT_METHOD(isRoot:(NSString *)navId sceneId:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
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

RCT_EXPORT_METHOD(replace:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        HBDViewController *target = [[HBDReactBridgeManager instance] controllerWithModuleName:moduleName props:props options:options];
        NSMutableArray *children = [vc.navigationController.childViewControllers mutableCopy];
        [children removeObjectAtIndex:children.count - 1];
        [children addObject:target];
        [vc.navigationController setViewControllers:[children copy] animated:NO];
    }
}

RCT_EXPORT_METHOD(replaceToRoot:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    if (vc.navigationController) {
        HBDViewController *target = [[HBDReactBridgeManager instance] controllerWithModuleName:moduleName props:props options:options];
        [vc.navigationController setViewControllers:@[target] animated:NO];
    }
}

RCT_EXPORT_METHOD(present:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName requestCode:(NSInteger)requestCode props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDViewController *vc = [self controllerForSceneId:sceneId];
    if (vc) {
        HBDNavigationController *presented = [[HBDNavigationController alloc] initWithRootModule:moduleName props:props options:options];
        [presented setRequestCode:requestCode];
        [vc presentViewController:presented animated:animated completion:^{
            
        }];
    }
}

RCT_EXPORT_METHOD(setResult:(NSString *)navId sceneId:(NSString *)sceneId resultCode:(NSInteger)resultCode data:(NSDictionary *)data) {
    HBDViewController *vc =  [self controllerForSceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(dismiss:(NSString *)navId sceneId:(NSString *)sceneId animated:(BOOL)animated) {
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

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout) {
    
}

RCT_EXPORT_METHOD(switchToTab:(NSInteger)index) {
    UITabBarController *tabBarController = [self tabBarController];
    if (tabBarController) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        tabBarController.selectedIndex = index;
    }
}

RCT_EXPORT_METHOD(setTabBadge:(NSInteger)index text:(NSString *)text) {
    UITabBarController *tabBarController = [self tabBarController];
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

- (UITabBarController *)tabBarController {
    UIViewController *vc = RCTPresentedViewController();
    return [self tabBarControllerAtController:vc];
}

- (UITabBarController *)tabBarControllerAtController:(UIViewController *)controller {
    UITabBarController *tabBarController;
    if ([controller isKindOfClass:[UITabBarController class]]) {
        tabBarController = (UITabBarController *)controller;
    }
    
    if (!tabBarController && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            tabBarController = [self tabBarControllerAtController:child];
            if (tabBarController) {
                break;
            }
        }
    }
    
    if (!tabBarController) {
        UIViewController *presenting = controller.presentingViewController;
        if (presenting) {
            tabBarController = [self tabBarControllerAtController:presenting];
        }
    }
    
    return tabBarController;
}


@end
