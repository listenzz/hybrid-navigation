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

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc root:(NSMutableArray *)root {
    if ([vc isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < nav.childViewControllers.count; i++) {
            UIViewController *child = nav.childViewControllers[i];
            [[HBDReactBridgeManager get] buildRouteGraphWithController:child root:children];
        }
        [root addObject:@{
                          @"layout": @"stack",
                          @"sceneId": vc.sceneId,
                          @"children": children,
                          @"mode": [vc hbd_mode],
                          }];
        return YES;
    }
    return NO;
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
    
    HBDViewController *viewController = nil;
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        viewController = [[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
        if (!viewController) {
            resolve(@(NO));
            return;
        }
    }

    if ([action isEqualToString:@"push"]) {
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
        HBDViewController *target;
        NSUInteger count = children.count;
        NSString *targetId = [extras objectForKey:@"targetId"];
        for (NSUInteger i = 0; i < count; i ++) {
            HBDViewController *vc = [children objectAtIndex:i];
            if ([vc.sceneId isEqualToString:targetId]) {
                target = vc;
                break;
            }
        }
        
        if (target) {
            nav.topViewController.didHideActionBlock = ^{
                resolve(@(YES));
            };
            [nav popToViewController:target animated:YES];
        } else {
            resolve(@(NO));
        }
    } else if ([action isEqualToString:@"popToRoot"]) {
        nav.topViewController.didHideActionBlock = ^{
            resolve(@(YES));
        };
        [nav popToRootViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"redirectTo"]) {
        viewController.didShowActionBlock = ^{
            resolve(@(YES));
        };
        [nav redirectToViewController:viewController target:target animated:YES];
    } else if ([action isEqualToString:@"pushLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *vc = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        if (vc) {
            vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            vc.didShowActionBlock = ^{
                resolve(@(YES));
            };
            [nav pushViewController:vc animated:YES];
        } else {
            resolve(@(NO));
        }
    }
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
