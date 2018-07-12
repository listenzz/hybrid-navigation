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
    return @[ @"switchToTab" ];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSArray *tabs = [layout objectForKey:self.name];
    if (tabs) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSDictionary *tab in tabs) {
            UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:tab];
            if (vc) {
                [controllers addObject:vc];
            }
        }
        
        if (controllers.count > 0) {
            HBDTabBarController *tabBarController = [[HBDTabBarController alloc] init];
            [tabBarController setViewControllers:controllers];
            
            NSDictionary *options = [layout objectForKey:@"options"];
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

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc graph:(NSMutableArray *)container {
    if ([vc isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabs = (HBDTabBarController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < tabs.childViewControllers.count; i++) {
            UIViewController *child = tabs.childViewControllers[i];
            [[HBDReactBridgeManager sharedInstance] routeGraphWithController:child container:children];
        }
        [container addObject:@{ @"type": self.name, self.name: children, @"selectedIndex": @(tabs.selectedIndex) }];
        return YES;
    }
    return NO;
}

- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVc = (UITabBarController *)vc;
        return [[HBDReactBridgeManager sharedInstance] primaryChildViewControllerInController:tabBarVc.selectedViewController];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras {
    UITabBarController *tabBarController = vc.tabBarController;
    if (!tabBarController) {
        return;
    }
    if ([action isEqualToString:@"switchToTab"]) {
        if (tabBarController.presentedViewController) {
            [tabBarController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        NSInteger index = [[extras objectForKey:@"index"] integerValue];
        tabBarController.selectedIndex = index;
    }
}

@end
