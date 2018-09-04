//
//  HBDGardenModule.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDGardenModule.h"
#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"
#import "HBDGarden.h"
#import "HBDUtils.h"
#import "UITabBar+Badge.h"

#import <React/RCTLog.h>

@interface HBDGardenModule()

@end

@implementation HBDGardenModule

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(GardenHybrid)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{
             @"DARK_CONTENT": @"dark-content",
             @"LIGHT_CONTENT": @"light-content",
             };
}

RCT_EXPORT_METHOD(setStyle:(NSDictionary *)style) {
    [HBDGarden createGlobalStyleWithOptions:style];
}

RCT_EXPORT_METHOD(setLeftBarButtonItem:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"leftBarButtonItem" forController:vc];
    [garden setLeftBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"rightBarButtonItem" forController:vc];
    [garden setRightBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setTitleItem:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"titleItem" forController:vc];
    [garden setTitleItem:item forController:vc];
}

RCT_EXPORT_METHOD(setTitleTextAttributes:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    NSMutableDictionary *titleAttributes = [vc.hbd_titleTextAttributes mutableCopy];
    if (!titleAttributes) {
        titleAttributes = [@{} mutableCopy];
    }
    NSString *titleTextColor = [item objectForKey:@"titleTextColor"];
    NSNumber *titleTextSize = [item objectForKey:@"titleTextSize"];
    if (titleTextColor) {
        [titleAttributes setObject:[HBDUtils colorWithHexString:titleTextColor] forKey:NSForegroundColorAttributeName];
    }
    if (titleTextSize) {
        [titleAttributes setObject:[UIFont systemFontOfSize:[titleTextSize floatValue]] forKey:NSFontAttributeName];
    }
    [garden setTitleTextAttributes:titleAttributes forController:vc];
}


RCT_EXPORT_METHOD(setStatusBarColor:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"setStatusBarColor: %@", item);
}

RCT_EXPORT_METHOD(setStatusBarHidden:(NSString *)sceneId item:(NSDictionary *)item) {
    NSNumber *statusBarHidden = [item objectForKey:@"statusBarHidden"];
    if (statusBarHidden) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:statusBarHidden forKey:@"statusBarHidden"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setStatusBarHidden:[statusBarHidden boolValue] forController:vc];
    }
}

RCT_EXPORT_METHOD(setTopBarStyle:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"setTopBarStyle: %@", item);
    NSString *topBarStyle = [item objectForKey:@"topBarStyle"];
    if (topBarStyle) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:topBarStyle forKey:@"topBarStyle"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        if ([topBarStyle isEqualToString:@"dark-content"]) {
            [garden setTopBarStyle:UIBarStyleDefault forController:vc];
        } else {
            [garden setTopBarStyle:UIBarStyleBlack forController:vc];
        }
    }
}

RCT_EXPORT_METHOD(setTopBarTintColor:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"setTopBarTintColor: %@", item);
    NSString *topBarTintColor = [item objectForKey:@"topBarTintColor"];
    if (topBarTintColor) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:topBarTintColor forKey:@"topBarTintColor"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setTopBarTintColor:[HBDUtils colorWithHexString:topBarTintColor] forController:vc];
    }
}

RCT_EXPORT_METHOD(setTopBarAlpha:(NSString *)sceneId item:(NSDictionary *)item) {
    NSNumber *topBarAlpha = [item objectForKey:@"topBarAlpha"];
    if (topBarAlpha) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:topBarAlpha forKey:@"topBarAlpha"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setTopBarAlpha:[topBarAlpha floatValue] forController:vc];
    }
    NSLog(@"setTopBarAlpha: %@", item);
}

RCT_EXPORT_METHOD(setTopBarColor:(NSString *)sceneId item:(NSDictionary *)item) {
    NSString *topBarColor = [item objectForKey:@"topBarColor"];
    if (topBarColor) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:topBarColor forKey:@"topBarColor"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setTopBarColor:[HBDUtils colorWithHexString:topBarColor] forController:vc];
    }
    NSLog(@"setTopBarColor: %@", item);
}

RCT_EXPORT_METHOD(setTabBarColor:(NSString *)sceneId item:(NSDictionary *)item) {
    NSString *tabBarColor = [item objectForKey:@"tabBarColor"];
    if (tabBarColor) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        UITabBarController *tabBarVC = vc.tabBarController;
        if (tabBarVC) {
            [tabBarVC.tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]]];
        }
    }
    NSLog(@"setTabBarColor: %@", item);
}

RCT_EXPORT_METHOD(setTopBarShadowHidden:(NSString *)sceneId item:(NSDictionary *)item) {
    NSNumber *topBarShadowHidden = [item objectForKey:@"topBarShadowHidden"];
    if (topBarShadowHidden) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:topBarShadowHidden forKey:@"topBarShadowHidden"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setTopBarShadowHidden:[topBarShadowHidden boolValue] forController:vc];
    }
    NSLog(@"setTopBarShadowHidden: %@", item);
}

RCT_EXPORT_METHOD(setTabBadge:(NSString *)sceneId index:(NSInteger)index text:(NSString *)text) {
    HBDViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    UITabBarController *tabBarController = vc.tabBarController;
    if (tabBarController) {
        UIViewController *vc = tabBarController.viewControllers[index];
        vc.tabBarItem.badgeValue = text;
    }
    NSLog(@"setTabBadge: %ld", (long)index);
}

RCT_EXPORT_METHOD(showRedPointAtIndex:(NSInteger)index sceneId:(NSString *)sceneId) {
    HBDViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    UITabBarController *tabBarController = vc.tabBarController;
    if (tabBarController) {
        UITabBar *tabBar = tabBarController.tabBar;
        [tabBar showRedPointAtIndex:index];
    }
    NSLog(@"showRedPointAtIndex: %ld", (long)index);
}

RCT_EXPORT_METHOD(hideRedPointAtIndex:(NSInteger)index sceneId:(NSString *)sceneId) {
    HBDViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    UITabBarController *tabBarController = vc.tabBarController;
    if (tabBarController) {
        UITabBar *tabBar = tabBarController.tabBar;
        [tabBar hideRedPointAtIndex:index];
    }
    NSLog(@"hideRedPointAtIndex: %ld", (long)index);
}

RCT_EXPORT_METHOD(replaceTabIcon:(NSString *)sceneId index:(NSInteger)index icon:(NSDictionary *)icon inactiveIcon:(NSDictionary *)selectedIcon) {
    HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    UITabBarController *tabBarVC = vc.tabBarController;
    if (tabBarVC) {
        UIViewController *tab = [tabBarVC.viewControllers objectAtIndex:index];
        UITabBarItem *tabBarItem = nil;
        if (selectedIcon) {
            UIImage *selectedImage = [[HBDUtils UIImage:selectedIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIImage *image = [[HBDUtils UIImage:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tabBarItem = [[UITabBarItem alloc] initWithTitle:tab.tabBarItem.title image:image selectedImage:selectedImage];
        } else {
            tabBarItem = [[UITabBarItem alloc] initWithTitle:tab.tabBarItem.title image:[HBDUtils UIImage:icon] selectedImage:nil];
        }
        tabBarItem.badgeValue = tab.tabBarItem.badgeValue;
        tab.tabBarItem = tabBarItem;
    }
    NSLog(@"replaceTabIcon: %ld", (long)index);
}

RCT_EXPORT_METHOD(replaceTabColor:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    UITabBarController *tabBarVC = vc.tabBarController;
    if (tabBarVC) {
        NSString *tabBarItemColor = item[@"tabBarItemColor"];
        if (tabBarItemColor) {
            tabBarVC.tabBar.tintColor = [HBDUtils colorWithHexString:tabBarItemColor];
        }
        NSString *tabBarUnselectedItemColor = item[@"tabBarUnselectedItemColor"];
        if (tabBarUnselectedItemColor) {
            if (@available(iOS 10.0, *)) {
                tabBarVC.tabBar.unselectedItemTintColor = [HBDUtils colorWithHexString:tabBarUnselectedItemColor];
            }
        }
    }
}

RCT_EXPORT_METHOD(setMenuInteractive:(NSString *)sceneId enabled:(BOOL)enabled) {
    HBDViewController *vc =  [[HBDReactBridgeManager sharedInstance] controllerForSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        drawer.menuInteractive = enabled;
    }
}

- (NSDictionary *)mergeItem:(NSDictionary *)item key:(NSString *)key forController:(HBDViewController *)vc {
    NSDictionary *options = vc.options;
    NSDictionary *target = options[key];
    if (!target) {
        target = @{};
    }
    target = [HBDUtils mergeItem:item withTarget:target];
    NSMutableDictionary *mutable =  [options mutableCopy];
    [mutable setObject:target forKey:key];
    vc.options = [mutable copy];
    
    return target;
}

@end
