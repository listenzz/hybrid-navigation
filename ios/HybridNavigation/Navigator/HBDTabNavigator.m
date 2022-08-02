#import "HBDTabNavigator.h"
#import "HBDTabBarController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "GlobalStyle.h"
#import <React/RCTUtils.h>

@implementation HBDTabNavigator

- (NSString *)name {
    return @"tabs";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"switchTab"];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *tabs = layout[self.name];
    NSArray *children = tabs[@"children"];
    if (children) {
        NSDictionary *options = tabs[@"options"];
        NSMutableDictionary *tabBarOptions = [@{} mutableCopy];
        NSString *tabBarModuleName = options[@"tabBarModuleName"];
        BOOL hasCustomTabBar = tabBarModuleName.length > 0;

        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSDictionary *tab in children) {
            UIViewController *vc = [[HBDReactBridgeManager get] controllerWithLayout:tab];
            if (vc) {
                [controllers addObject:vc];
            }
        }

        if (hasCustomTabBar) {
            NSArray *tabInfos = [self tabsInfoWithChildren:controllers];
            tabBarOptions[@"tabs"] = tabInfos;
            tabBarOptions[@"tabBarModuleName"] = tabBarModuleName;
            tabBarOptions[@"sizeIndeterminate"] = @([options[@"sizeIndeterminate"] boolValue]);
            tabBarOptions[@"selectedIndex"] = options[@"selectedIndex"] ?: @(0);
            GlobalStyle *style = [GlobalStyle globalStyle];
            tabBarOptions[@"tabBarItemColor"] = style.tabBarItemColorHexString;
            tabBarOptions[@"tabBarUnselectedItemColor"] = style.tabBarUnselectedItemColorHexString;
            tabBarOptions[@"badgeColor"] = style.badgeColorHexString;
        }

        HBDTabBarController *tabBarController = nil;

        if (hasCustomTabBar) {
            tabBarController = [[HBDTabBarController alloc] initWithTabBarOptions:tabBarOptions];
        } else {
            tabBarController = [[HBDTabBarController alloc] init];
        }

        [tabBarController setViewControllers:controllers];

        if (options) {
            NSNumber *selectedIndex = options[@"selectedIndex"];
            if (selectedIndex) {
                tabBarController.intercepted = NO;
                tabBarController.selectedIndex = (NSUInteger) [selectedIndex integerValue];
                tabBarController.intercepted = YES;
            }
        }

        return tabBarController;
    }
    return nil;
}

- (NSArray<NSDictionary *> *)tabsInfoWithChildren:(NSArray<UIViewController *> *)children {
    NSUInteger count = children.count;
    UIViewController *vc = nil;
    NSMutableArray *tabInfos = [[NSMutableArray alloc] initWithCapacity:4];
    for (NSUInteger i = 0; i < count; i++) {
        vc = children[i];
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *) vc;
            vc = nav.childViewControllers[0];
        }
        if ([vc isKindOfClass:[HBDViewController class]]) {
            HBDViewController *hbdVC = (HBDViewController *) vc;
            NSDictionary *tabItem = hbdVC.options[@"tabItem"];
            if (tabItem) {
                NSDictionary *tab = @{
                        @"index": @(i),
                        @"sceneId": hbdVC.sceneId,
                        @"moduleName": RCTNullIfNil(hbdVC.moduleName),
                        @"icon": RCTNullIfNil([HBDUtils iconUriFromUri:tabItem[@"icon"][@"uri"]]),
                        @"unselectedIcon": RCTNullIfNil([HBDUtils iconUriFromUri:tabItem[@"unselectedIcon"][@"uri"]]),
                        @"title": RCTNullIfNil(tabItem[@"title"]),
                };
                [tabInfos addObject:tab];
            }
        }
    }
    return [tabInfos copy];
}

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarController = (HBDTabBarController *) vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < tabBarController.childViewControllers.count; i++) {
            UIViewController *child = tabBarController.childViewControllers[i];
            NSDictionary *graph = [[HBDReactBridgeManager get] buildRouteGraphWithViewController:child];
            [children addObject:graph];
        }
        return @{
                @"layout": self.name,
                @"sceneId": vc.sceneId,
                @"children": children,
                @"mode": [vc hbd_mode],
                @"selectedIndex": @(tabBarController.selectedIndex)
        };
    }
    return nil;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVc = (UITabBarController *) vc;
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:tabBarVc.selectedViewController];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {

    UITabBarController *tabBarController = nil;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        tabBarController = (UITabBarController *) vc;
    } else {
        tabBarController = vc.tabBarController;
    }

    if (!tabBarController) {
        resolve(@(NO));
        return;
    }

    if (!tabBarController.hbd_viewAppeared) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleNavigationWithViewController:vc action:action extras:extras resolver:resolve rejecter:reject];
        });
        return;
    }

    if ([action isEqualToString:@"switchTab"]) {
        BOOL popToRoot = [extras[@"popToRoot"] boolValue];
        NSNumber *from = extras[@"from"];
        NSUInteger to = [extras[@"to"] integerValue];

        if (from && [from integerValue] == to) {
            resolve(@(YES));
            return;
        }

        if (popToRoot) {
            UIViewController *selectedViewController = [tabBarController selectedViewController];
            UINavigationController *nav = nil;
            if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                nav = (UINavigationController *) selectedViewController;
            } else {
                nav = selectedViewController.navigationController;
            }

            if (nav && nav.childViewControllers.count > 1) {
                [nav popToRootViewControllerAnimated:NO];
            }
        }

        if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
            HBDTabBarController *hbdTabBarVC = (HBDTabBarController *) tabBarController;
            hbdTabBarVC.intercepted = NO;
            tabBarController.selectedIndex = to;
            hbdTabBarVC.intercepted = YES;
        } else {
            tabBarController.selectedIndex = to;
        }
    }

    resolve(@(YES));
}

@end
