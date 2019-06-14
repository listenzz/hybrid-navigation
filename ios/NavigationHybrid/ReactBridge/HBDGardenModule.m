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
#import "HBDTabBarController.h"
#import "HBDGarden.h"
#import "HBDUtils.h"

#import <React/RCTLog.h>

@interface HBDGardenModule()

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDGardenModule

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(GardenHybrid)

- (instancetype)init {
    if (self = [super init]) {
        _bridgeManager = [HBDReactBridgeManager sharedInstance];
    }
    return self;
}

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
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"leftBarButtonItem" forController:vc];
    [garden setLeftBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"rightBarButtonItem" forController:vc];
    [garden setRightBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setTitleItem:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"titleItem" forController:vc];
    [garden setTitleItem:item forController:vc];
}

- (HBDViewController *)HBDViewControllerForSceneId:(NSString *)sceneId {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *)vc;
    }
    return nil;
}

RCT_EXPORT_METHOD(setStatusBarColor:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"setStatusBarColor: %@", item);
}

RCT_EXPORT_METHOD(setStatusBarHidden:(NSString *)sceneId item:(NSDictionary *)item) {
    NSNumber *statusBarHidden = [item objectForKey:@"statusBarHidden"];
    if (statusBarHidden) {
        HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:statusBarHidden forKey:@"statusBarHidden"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setStatusBarHidden:[statusBarHidden boolValue] forController:vc];
    }
}

RCT_EXPORT_METHOD(setPassThroughTouches:(NSString *)sceneId item:(NSDictionary *)item) {
    NSNumber *passThroughTouches = [item objectForKey:@"passThroughTouches"];
    if (passThroughTouches) {
        HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
        NSDictionary *options = vc.options;
        NSMutableDictionary *mutable =  [options mutableCopy];
        [mutable setObject:passThroughTouches forKey:@"passThroughTouches"];
        vc.options = [mutable copy];
        HBDGarden *garden = [[HBDGarden alloc] init];
        [garden setPassThroughTouches:[passThroughTouches boolValue] forController:vc];
    }
    NSLog(@"setPassThroughTouches: %@", item);
}

RCT_EXPORT_METHOD(updateTopBar:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"updateTopBar: %@", item);
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    [(HBDViewController *)vc updateNavigationBar:item];
}

RCT_EXPORT_METHOD(updateTabBar:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"updateTabBar: %@", item);
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarVC = [self tabBarControllerWithViewController:vc];
    if (tabBarVC && [tabBarVC isKindOfClass:[HBDTabBarController class]]) {
        [((HBDTabBarController *)tabBarVC) updateTabBar:item];
    }
}

RCT_EXPORT_METHOD(setTabBadgeText:(NSString *)sceneId index:(NSInteger)index text:(NSString *)text) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
        [tabBarVC setBadgeText:text atIndex:index];
    }
    NSLog(@"setTabBadgeText: %ld, %@", (long)index, text);
}

RCT_EXPORT_METHOD(showRedPointAtIndex:(NSInteger)index sceneId:(NSString *)sceneId) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
        [tabBarVC setRedPointVisible:YES atIndex:index];
    }
    NSLog(@"showRedPointAtIndex: %ld", (long)index);
}

RCT_EXPORT_METHOD(hideRedPointAtIndex:(NSInteger)index sceneId:(NSString *)sceneId) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
        [tabBarVC setRedPointVisible:NO atIndex:index];
    }
    NSLog(@"hideRedPointAtIndex: %ld", (long)index);
}

RCT_EXPORT_METHOD(replaceTabIcon:(NSString *)sceneId index:(NSInteger)index icon:(NSDictionary *)icon inactiveIcon:(NSDictionary *)selectedIcon) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
        NSMutableDictionary *options = [@{@"icon": icon} mutableCopy];
        if (selectedIcon) {
            [options setObject:selectedIcon forKey:@"selectedIcon"];
        }
        [tabBarVC updateTabBarItem:options atIndex:index];
    }
    NSLog(@"replaceTabIcon: %ld", (long)index);
}

- (UITabBarController *)tabBarControllerWithViewController:(UIViewController *)vc {
    UITabBarController *tabBarController;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        tabBarController = (UITabBarController *)vc;
    } else {
        tabBarController = vc.tabBarController;
    }
    return tabBarController;
}

RCT_EXPORT_METHOD(setMenuInteractive:(NSString *)sceneId enabled:(BOOL)enabled) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
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
