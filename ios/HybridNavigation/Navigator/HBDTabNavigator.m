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

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *tabs = layout[self.name];
    NSArray *children = tabs[@"children"];
    if (!children) {
        return nil;
    }
   
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:4];
    for (NSDictionary *tab in children) {
        UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:tab];
        [controllers addObject:vc];
    }
    
    NSDictionary *options = tabs[@"options"];
    NSArray *tabInfos = [self tabInfosWithChildren:controllers];
    HBDTabBarController * tabBarController = [self createTabBarControllerWithTabInfos:tabInfos options:options];
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

- (HBDTabBarController *)createTabBarControllerWithTabInfos:(NSArray *)tabInfos options:(NSDictionary *)options  {
    NSString *moduleName = options[@"tabBarModuleName"];
    BOOL hasCustomTabBar = moduleName.length > 0;
    
    if (!hasCustomTabBar) {
        return [[HBDTabBarController alloc] init];
    }
    
    GlobalStyle *style = [GlobalStyle globalStyle];
    
    NSDictionary *tabBarOptions = @{
        @"tabs":                      tabInfos,
        @"tabBarModuleName":          moduleName,
        @"sizeIndeterminate":         options[@"sizeIndeterminate"],
        @"selectedIndex":             options[@"selectedIndex"] ?: @(0),
        @"tabBarItemColor":           style.tabBarItemColorHexString,
        @"tabBarUnselectedItemColor": style.tabBarUnselectedItemColorHexString,
        @"badgeColor":                style.badgeColorHexString,
    };

    return [[HBDTabBarController alloc] initWithTabBarOptions:tabBarOptions];
}

- (NSArray<NSDictionary *> *)tabInfosWithChildren:(NSArray<UIViewController *> *)children {
    NSUInteger count = children.count;
    NSMutableArray *tabInfos = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (NSUInteger i = 0; i < count; i++) {
        UIViewController *vc = children[i];
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

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDTabBarController class]]) {
        return nil;
    }
    
    HBDTabBarController *tabBarController = (HBDTabBarController *) vc;
    NSMutableArray *children = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < tabBarController.childViewControllers.count; i++) {
        UIViewController *child = tabBarController.childViewControllers[i];
        NSDictionary *graph = [[HBDReactBridgeManager get] routeGraphWithViewController:child];
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

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[UITabBarController class]]) {
        return nil;
    }
    UITabBarController *tabBarVc = (UITabBarController *) vc;
    return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:tabBarVc.selectedViewController];
}

- (UITabBarController *)tabBarControllerForViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return (UITabBarController *) vc;
    } else {
        return vc.tabBarController;
    }
}

- (void)handleSwitchTabWithTabBarController:(UITabBarController *)tabBarController extras:(NSDictionary *)extras resolve:(RCTPromiseResolveBlock)resolve {
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
    
    resolve(@(YES));
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {

    UITabBarController * tabBarController = [self tabBarControllerForViewController:vc];

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
        [self handleSwitchTabWithTabBarController:tabBarController extras:extras resolve:resolve];
        return;
    }
}

@end
