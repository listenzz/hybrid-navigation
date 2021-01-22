//
//  HBDStackNavigator.m
//  NavigationHybrid
//
//  Created by Listen on 2018/6/28.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDStackNavigator.h"
#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"
#import "UINavigationController+HBD.h"

@implementation HBDStackNavigator

- (NSString *)name {
    return @"stack";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"push", @"pushLayout", @"pop", @"popTo", @"popToRoot", @"redirectTo"];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *stack = [layout objectForKey:self.name];
    if (stack) {
        NSArray *children = [stack objectForKey:@"children"];
        UIViewController *root = [[HBDReactBridgeManager get] controllerWithLayout:children.firstObject];
        if (root) {
            return [[HBDNavigationController alloc] initWithRootViewController:root];
        }
    }
    return nil;
}

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < nav.childViewControllers.count; i++) {
            UIViewController *child = nav.childViewControllers[i];
            NSDictionary *graph = [[HBDReactBridgeManager get] buildRouteGraphWithViewController:child];
            [children addObject:graph];
        }
        
        return @{
            @"layout": @"stack",
            @"sceneId": vc.sceneId,
            @"children": children,
            @"mode": [vc hbd_mode],
        };
    }
    return nil;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:nav.topViewController];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    UINavigationController *nav = [self navigationControllerForController:target];
    if (!nav) {
        resolve(@(NO));
        return;
    }
    
    if (!nav.hbd_viewAppeared) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
        });
        return;
    }
    
    UIViewController *viewController = nil;

    if ([action isEqualToString:@"push"]) {
        viewController = [self createViewControllerWithExtras:extras];
        if (!viewController) {
            resolve(@(NO));
            return;
        }
        viewController.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
        viewController.didShowActionBlock = ^{
            resolve(@(YES));
        };
        [nav pushViewController:viewController animated:YES];
    } else if ([action isEqualToString:@"pop"]) {
        nav.topViewController.didHideActionBlock = ^{
            resolve(@(YES));
        };
        [nav popViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"popTo"]) {
        NSArray *children = nav.childViewControllers;
        NSInteger count = children.count;
        NSString *moduleName = [extras objectForKey:@"moduleName"];
        for (NSInteger i = count - 1; i > -1; i--) {
            HBDViewController *vc = [children objectAtIndex:i];
            if ([moduleName isEqualToString:vc.moduleName] || [moduleName isEqualToString:vc.sceneId]) {
                viewController = vc;
                break;
            }
        }
        
        if (viewController) {
            nav.topViewController.didHideActionBlock = ^{
                resolve(@(YES));
            };
            [nav popToViewController:viewController animated:YES];
        } else {
            resolve(@(NO));
        }
    } else if ([action isEqualToString:@"popToRoot"]) {
        nav.topViewController.didHideActionBlock = ^{
            resolve(@(YES));
        };
        [nav popToRootViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"redirectTo"]) {
        viewController = [self createViewControllerWithExtras:extras];
        if (!viewController) {
            resolve(@(NO));
            return;
        }
        viewController.didShowActionBlock = ^{
            resolve(@(YES));
        };
        [nav redirectToViewController:viewController target:target animated:YES];
    } else if ([action isEqualToString:@"pushLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        if (viewController) {
            viewController.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            viewController.didShowActionBlock = ^{
                resolve(@(YES));
            };
            [nav pushViewController:viewController animated:YES];
        } else {
            resolve(@(NO));
        }
    }
}

- (UIViewController *)createViewControllerWithExtras:(NSDictionary *)extras {
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    HBDViewController *viewController = nil;
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        viewController = [[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }
    return viewController;
}

- (UINavigationController *)navigationControllerForController:(UIViewController *)controller {
    UINavigationController *nav = nil;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *)controller;
    } else {
        nav = controller.navigationController;
    }
    
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
            nav = drawer.contentController.navigationController;
        }
    }
    return nav;
}

@end
