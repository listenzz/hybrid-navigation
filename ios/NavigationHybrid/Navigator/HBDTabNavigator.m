//
//  HBDTabNavigator.m
//  NavigationHybrid
//
//  Created by Listen on 2018/6/28.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDTabNavigator.h"
#import "HBDTabBarController.h"
#import "HBDReactBridgeManager.h"

@implementation HBDTabNavigator

- (NSString *)name {
    return @"tabs";
}

- (NSArray<NSString *> *)supportActions {
    return @[ @"switchTab" ];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *tabs = [layout objectForKey:self.name];
    NSArray *children = [tabs objectForKey:@"children"];
    if (children) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSDictionary *tab in children) {
            UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:tab];
            if (vc) {
                [controllers addObject:vc];
            }
        }
        
        if (controllers.count > 0) {
            HBDTabBarController *tabBarController = [[HBDTabBarController alloc] init];
            [tabBarController setViewControllers:controllers];
            
            NSDictionary *options = [tabs objectForKey:@"options"];
            if (options) {
                NSNumber *selectedIndex = [options objectForKey:@"selectedIndex"];
                if (selectedIndex) {
                    tabBarController.selectedIndex = [selectedIndex integerValue];
                }
            }
            
            return tabBarController;
        }
    }
    return nil;
}

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc root:(NSMutableArray *)root {
    if ([vc isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarController = (HBDTabBarController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < tabBarController.childViewControllers.count; i++) {
            UIViewController *child = tabBarController.childViewControllers[i];
            [[HBDReactBridgeManager sharedInstance] buildRouteGraphWithController:child root:children];
        }
        [root addObject:@{
                          @"layout": self.name,
                          @"sceneId": vc.sceneId,
                          @"children": children,
                          @"mode": [vc hbd_mode],
                          @"state": @{
                                  @"selectedIndex": @(tabBarController.selectedIndex)
                              }
                          }];
        return YES;
    }
    return NO;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVc = (UITabBarController *)vc;
        return [[HBDReactBridgeManager sharedInstance] primaryViewControllerWithViewController:tabBarVc.selectedViewController];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras {
    UITabBarController *tabBarController = vc.tabBarController;
    if (!tabBarController) {
        return;
    }
    if ([action isEqualToString:@"switchTab"]) {
        if (tabBarController.presentedViewController && !tabBarController.presentedViewController.isBeingDismissed) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        NSInteger index = [[extras objectForKey:@"index"] integerValue];
        tabBarController.selectedIndex = index;
    }
}

@end
