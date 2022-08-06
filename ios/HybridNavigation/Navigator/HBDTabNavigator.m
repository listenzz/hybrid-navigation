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
    NSDictionary *model = layout[self.name];
    NSArray *children = model[@"children"];
    if (!children) {
        return nil;
    }
   
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:4];
    for (NSDictionary *tab in children) {
        UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:tab];
        [viewControllers addObject:vc];
    }
    
    NSDictionary *options = model[@"options"];
    NSArray *tabModels = [self tabModelsWithViewControllers:viewControllers];
    HBDTabBarController *tabBarController = [self createTabBarControllerWithTabModels:tabModels options:options];
    [tabBarController setViewControllers:viewControllers];

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

- (HBDTabBarController *)createTabBarControllerWithTabModels:(NSArray *)tabModels options:(NSDictionary *)options  {
    NSString *moduleName = options[@"tabBarModuleName"];
    BOOL hasCustomTabBar = moduleName.length > 0;
    
    if (!hasCustomTabBar) {
        return [[HBDTabBarController alloc] init];
    }
    
    GlobalStyle *style = [GlobalStyle globalStyle];
    
    NSDictionary *tabBarOptions = @{
        @"tabs":                      tabModels,
        @"tabBarModuleName":          moduleName,
        @"sizeIndeterminate":         options[@"sizeIndeterminate"],
        @"selectedIndex":             options[@"selectedIndex"] ?: @(0),
        @"tabBarItemColor":           style.tabBarItemColorHexString,
        @"tabBarUnselectedItemColor": style.tabBarUnselectedItemColorHexString,
        @"badgeColor":                style.badgeColorHexString,
    };

    return [[HBDTabBarController alloc] initWithTabBarOptions:tabBarOptions];
}

- (NSArray<NSDictionary *> *)tabModelsWithViewControllers:(NSArray<UIViewController *> *)children {
    NSUInteger count = children.count;
    NSMutableArray *tabModels = [[NSMutableArray alloc] initWithCapacity:4];
    
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
                [tabModels addObject:tab];
            }
        }
    }
    
    return [tabModels copy];
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
        @"sceneId": tabBarController.sceneId,
        @"children": children,
        @"mode": [tabBarController hbd_mode],
        @"selectedIndex": @(tabBarController.selectedIndex)
    };
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[UITabBarController class]]) {
        return nil;
    }
    UITabBarController *tabBarController = (UITabBarController *) vc;
    return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:tabBarController.selectedViewController];
}

- (UITabBarController *)tabBarControllerForViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return (UITabBarController *) vc;
    } else {
        return vc.tabBarController;
    }
}

- (void)handleSwitchTabWithTabBarController:(UITabBarController *)tabBarController extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    BOOL popToRoot = [extras[@"popToRoot"] boolValue];
    NSNumber *from = extras[@"from"];
    NSUInteger to = [extras[@"to"] integerValue];
    
    if (from && [from integerValue] == to) {
        callback(@[NSNull.null, @YES]);
        return;
    }
    
    if (popToRoot) {
        UIViewController *selectedViewController = [tabBarController selectedViewController];
        UINavigationController *nav = nil;
        if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)selectedViewController;
        } else {
            nav = selectedViewController.navigationController;
        }
        
        if (nav && nav.childViewControllers.count > 1) {
            [nav popToRootViewControllerAnimated:NO];
        }
    }
    
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *hbdTabBarController = (HBDTabBarController *)tabBarController;
        hbdTabBarController.intercepted = NO;
        tabBarController.selectedIndex = to;
        hbdTabBarController.intercepted = YES;
    } else {
        tabBarController.selectedIndex = to;
    }
    
    callback(@[NSNull.null, @YES]);
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    if (!vc.hbd_inViewHierarchy) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    UITabBarController *tabBarController = [self tabBarControllerForViewController:vc];

    if (!tabBarController) {
        callback(@[NSNull.null, @NO]);
        return;
    }

    if (!tabBarController.hbd_viewAppeared) {
        [self performSelector:@selector(handleNavigation:) withObject:@{
            @"viewController": vc,
            @"action": action,
            @"extras": extras,
            @"callback": callback,
        } afterDelay:0.05];
        return;
    }

    if ([action isEqualToString:@"switchTab"]) {
        [self handleSwitchTabWithTabBarController:tabBarController extras:extras callback:callback];
        return;
    }
}

-(void)handleNavigation:(NSDictionary *)params {
    [self handleNavigationWithViewController:params[@"viewController"] action:params[@"action"] extras:params[@"extras"] callback:params[@"callback"]];
}

- (void)invalidate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
