//
//  HBDGardenModule.m
//  Pods
//
//  Created by Listen on 2017/11/26.
//

#import "HBDGardenModule.h"
#import "HBDNavigator.h"
#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"
#import "HBDGarden.h"
#import "HBDUtils.h"

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
             @"LIGHT_CONTENT": @"lieht-content",
             };
}

RCT_EXPORT_METHOD(setStyle:(NSDictionary *)style) {
    [HBDGarden setStyle:style];
}

RCT_EXPORT_METHOD(setLeftBarButtonItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"leftBarButtonItem" forController:vc];
    [garden setLeftBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"rightBarButtonItem" forController:vc];
    [garden setRightBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setTitleItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"titleItem" forController:vc];
    [garden setTitleItem:item forController:vc];
}

- (HBDReactViewController *)controllerForNavId:(NSString *)navId sceneId:(NSString *)sceneId {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    if (navigator) {
        UIViewController *vc = navigator.navigationController.topViewController;
        if ([vc isKindOfClass:[HBDReactViewController class]]) {
            HBDReactViewController *hbdvc = (HBDReactViewController *)vc;
            if ([hbdvc.sceneId isEqualToString:sceneId]) {
                return hbdvc;
            }
        }
        RCTLogWarn(@"top controller 不是要找的 controller，似乎哪个地方出错了");
    }
    return nil;
}

- (HBDNavigator *)navigatorForNavId:(NSString *)navId {
    HBDNavigator *navigator = [HBDNavigator navigatorForId:navId];
    if (!navigator) {
        NSLog(@"找不到对应的 navigator，似乎哪个地方出错了");
    }
    return navigator;
}

- (NSDictionary *)mergeItem:(NSDictionary *)item key:(NSString *)key forController:(HBDReactViewController *)vc {
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
