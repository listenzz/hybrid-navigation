//
//  HBDGardenModule.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDGardenModule.h"
#import "HBDReactBridgeManager.h"
#import "HBDViewController.h"
#import "HBDTabBarController.h"
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
        _bridgeManager = [HBDReactBridgeManager get];
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

RCT_EXPORT_METHOD(setTitleItem:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    if (vc) {
        [(HBDViewController *)vc updateOptions:@{ @"titleItem": item}];
    }
}

RCT_EXPORT_METHOD(setLeftBarButtonItem:(NSString *)sceneId item:(NSDictionary * __nullable)item) {
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    if (vc) {
        [(HBDViewController *)vc updateOptions:@{ @"leftBarButtonItem": item ?: NSNull.null}];
    }
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *)sceneId item:(NSDictionary * __nullable)item) {
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    if (vc) {
        [(HBDViewController *)vc updateOptions:@{ @"rightBarButtonItem": item ?: NSNull.null }];
    }
}

RCT_EXPORT_METHOD(updateOptions:(NSString *)sceneId item:(NSDictionary *)options) {
    NSLog(@"updateOptions: %@", options);
    HBDViewController *vc = [self HBDViewControllerForSceneId:sceneId];
    if (vc) {
        [(HBDViewController *)vc updateOptions:options];
    }
}

RCT_EXPORT_METHOD(updateTabBar:(NSString *)sceneId item:(NSDictionary *)item) {
    NSLog(@"updateTabBar: %@", item);
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarVC = [self tabBarControllerWithViewController:vc];
    if (tabBarVC && [tabBarVC isKindOfClass:[HBDTabBarController class]]) {
        [((HBDTabBarController *)tabBarVC) updateTabBar:item];
    }
}

RCT_EXPORT_METHOD(setTabBadge:(NSString *)sceneId options:(NSArray<NSDictionary *> *)options) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
        [tabBarVC setTabBadge:options];
    }
    NSLog(@"setTabBadge: %@", options);
}

RCT_EXPORT_METHOD(setTabIcon:(NSString *)sceneId options:(NSArray<NSDictionary *> *)options) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
        [tabBarVC setTabIcon:options];
    }
    NSLog(@"setTabIcon: %@", options);
}

RCT_EXPORT_METHOD(setMenuInteractive:(NSString *)sceneId enabled:(BOOL)enabled) {
    UIViewController *vc =  [self.bridgeManager controllerForSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        drawer.menuInteractive = enabled;
    }
}

- (HBDViewController *)HBDViewControllerForSceneId:(NSString *)sceneId {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *)vc;
    }
    return nil;
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

@end
