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
    return @[@"push", @"pushLayout", @"pop", @"popTo", @"popToRoot", @"replace", @"replaceToRoot"];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *stack = [layout objectForKey:self.name];
    if (stack) {
        UIViewController *root = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:stack];
        NSDictionary *options = [layout objectForKey:@"options"];
        if (options) {
            // nothing to do now.
        }
        if (root) {
            return [[HBDNavigationController alloc] initWithRootViewController:root];
        }
    }
    return nil;
}

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc graph:(NSMutableArray *)container {
    if ([vc isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *stack = (HBDNavigationController *)vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < stack.childViewControllers.count; i++) {
            UIViewController *child = stack.childViewControllers[i];
            [[HBDReactBridgeManager sharedInstance] routeGraphWithController:child container:children];
        }
        [container addObject:@{ @"type": @"stack", @"stack": children }];
        return YES;
    }
    return NO;
}

- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [[HBDReactBridgeManager sharedInstance] primaryChildViewControllerInController:nav.topViewController];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras {
    UINavigationController *nav = [self navigationControllerForController:vc];
    if (!nav) {
        return;
    }
    
    HBDViewController *target = nil;
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        target =[[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
    }
    BOOL animated = [[extras objectForKey:@"animated"] boolValue];
    
    if ([action isEqualToString:@"push"]) {
        if (target) {
            target.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            [nav pushViewController:target animated:animated];
        }
    } else if ([action isEqualToString:@"pop"]) {
        [nav popViewControllerAnimated:animated];
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
            [nav popToViewController:target animated:animated];
        }
    } else if ([action isEqualToString:@"popToRoot"]) {
        [nav popToRootViewControllerAnimated:animated];
    } else if ([action isEqualToString:@"replace"]) {
        [nav replaceViewController:target animated:YES];
    } else if ([action isEqualToString:@"replaceToRoot"]) {
        [nav replaceToRootViewController:target animated:YES];
    } else if ([action isEqualToString:@"pushLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
        if (vc) {
            vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            [nav pushViewController:vc animated:animated];
        }
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
            nav = drawer.contentController.navigationController;
        }
    }
    return nav;
}

@end
