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

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras {
    UINavigationController *nav = [self navigationControllerForController:target];
    if (!nav) {
        return;
    }
    
    HBDViewController *viewController = nil;
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        viewController =[[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }

    if ([action isEqualToString:@"push"]) {
        if (viewController) {
            viewController.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            [nav pushViewController:viewController animated:YES];
        }
    } else if ([action isEqualToString:@"pop"]) {
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
            [nav popToViewController:target animated:YES];
        }
    } else if ([action isEqualToString:@"popToRoot"]) {
        [nav popToRootViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"redirectTo"]) {
        [nav redirectToViewController:viewController target:target animated:YES];
    } else if ([action isEqualToString:@"pushLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *vc = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        if (vc) {
            vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            [nav pushViewController:vc animated:YES];
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
