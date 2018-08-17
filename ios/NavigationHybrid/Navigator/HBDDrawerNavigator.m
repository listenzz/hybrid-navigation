//
//  HBDDrawerNavigator.m
//  NavigationHybrid
//
//  Created by Listen on 2018/6/28.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDDrawerNavigator.h"
#import "HBDReactBridgeManager.h"

@implementation HBDDrawerNavigator

- (NSString *)name {
    return @"drawer";
}

- (NSArray<NSString *> *)supportActions {
    return @[ @"toggleMenu", @"openMenu", @"closeMenu" ];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSArray *drawer = [layout objectForKey:self.name];
    if (drawer && drawer.count == 2) {
        NSDictionary *content = [drawer objectAtIndex:0];
        NSDictionary *menu = [drawer objectAtIndex:1];
        
        UIViewController *contentController = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:content];
        UIViewController *menuController = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:menu];
        
        if (contentController && menuController) {
            HBDDrawerController *drawerController = [[HBDDrawerController alloc] initWithContentViewController:contentController menuViewController:menuController];
            NSDictionary *options = [layout objectForKey:@"options"];
            if (options) {
                NSNumber *maxDrawerWidth = [options objectForKey:@"maxDrawerWidth"];
                NSNumber *minDrawerMargin = [options objectForKey:@"minDrawerMargin"];
                NSNumber *menuInteractive = [options objectForKey:@"menuInteractive"];
                if (maxDrawerWidth) {
                    [drawerController setMaxDrawerWidth:[maxDrawerWidth floatValue]];
                }
                
                if (minDrawerMargin) {
                    [drawerController setMinDrawerMargin:[minDrawerMargin floatValue]];
                }
                
                if (menuInteractive) {
                    drawerController.menuInteractive = [menuInteractive boolValue];
                }
            }
            return drawerController;
        }
    }
    return nil;
}

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc graph:(NSMutableArray *)container {
    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        [[HBDReactBridgeManager sharedInstance] routeGraphWithController:drawer.contentController container:children];
        [[HBDReactBridgeManager sharedInstance] routeGraphWithController:drawer.menuController container:children];
        [container addObject:@{ @"type": @"drawer", @"drawer": children }];
        return YES;
    }
    return NO;
}

- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)vc;
        if (drawer.isMenuOpened) {
            return [[HBDReactBridgeManager sharedInstance] primaryChildViewControllerInController:drawer.menuController];
        } else {
            return [[HBDReactBridgeManager sharedInstance] primaryChildViewControllerInController:drawer.contentController];
        }
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras {
    HBDDrawerController *drawer = [vc drawerController];
    if (!drawer) {
        return;
    }
    
    if ([action isEqualToString:@"toggleMenu"]) {
        [drawer toggleMenu];
    } else if ([action isEqualToString:@"openMenu"]) {
        [drawer openMenu];
    } else if ([action isEqualToString:@"closeMenu"]) {
        [drawer closeMenu];
    }
}

@end
