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
    NSDictionary *drawer = [layout objectForKey:self.name];
    NSArray *children = [drawer objectForKey:@"children"];
    if (children.count == 2) {
        NSDictionary *content = [children objectAtIndex:0];
        NSDictionary *menu = [children objectAtIndex:1];
        
        UIViewController *contentController = [[HBDReactBridgeManager get] controllerWithLayout:content];
        UIViewController *menuController = [[HBDReactBridgeManager get] controllerWithLayout:menu];
        
        if (contentController && menuController) {
            HBDDrawerController *drawerController = [[HBDDrawerController alloc] initWithContentViewController:contentController menuViewController:menuController];
            NSDictionary *options = [drawer objectForKey:@"options"];
            if (options) {
                NSNumber *maxDrawerWidth = [options objectForKey:@"maxDrawerWidth"];
                if (maxDrawerWidth) {
                    [drawerController setMaxDrawerWidth:[maxDrawerWidth floatValue]];
                }
                
                NSNumber *minDrawerMargin = [options objectForKey:@"minDrawerMargin"];
                if (minDrawerMargin) {
                    [drawerController setMinDrawerMargin:[minDrawerMargin floatValue]];
                }
                
                NSNumber *menuInteractive = [options objectForKey:@"menuInteractive"];
                if (menuInteractive) {
                    drawerController.menuInteractive = [menuInteractive boolValue];
                }
            }
            return drawerController;
        }
    }
    return nil;
}

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc root:(NSMutableArray *)root {
    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        [[HBDReactBridgeManager get] buildRouteGraphWithController:drawer.contentController root:children];
        [[HBDReactBridgeManager get] buildRouteGraphWithController:drawer.menuController root:children];
        [root addObject:@{
                          @"layout": @"drawer",
                          @"sceneId": vc.sceneId,
                          @"children": children,
                          @"mode": [vc hbd_mode],
                        }];
        return YES;
    }
    return NO;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)vc;
        if (drawer.isMenuOpened) {
            return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:drawer.menuController];
        } else {
            return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:drawer.contentController];
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
