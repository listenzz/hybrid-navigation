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
#import <React/RCTLog.h>

@interface HBDGardenModule()

@end

@implementation HBDGardenModule

RCT_EXPORT_MODULE(GardenHybrid)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(setTopBarStyle:(NSString *)style) {
    [HBDGarden setTopBarStyle:style];
}

RCT_EXPORT_METHOD(setStatusBarColor:(NSString *)color) {
    // only for android
}

RCT_EXPORT_METHOD(setHideBackTitle:(BOOL)hidden) {
    [HBDGarden setHideBackTitle:hidden];
}

RCT_EXPORT_METHOD(setBackIcon:(NSDictionary *)icon) {
    [HBDGarden setBackIcon:icon];
}

RCT_EXPORT_METHOD(setTopBarBackgroundColor:(NSString *)color) {
    [HBDGarden setTopBarBackgroundColor:color];
}

RCT_EXPORT_METHOD(setTopBarTintColor:(NSString *)color) {
    [HBDGarden setTopBarTintColor:color];
}

RCT_EXPORT_METHOD(setTitleTextColor:(NSString *)color) {
    // TODO
}

RCT_EXPORT_METHOD(setTitleTextSize:(NSUInteger)dp) {
    // TODO
}

RCT_EXPORT_METHOD(setTitleAlignment:(NSString *)alignment) {
    // only for android
}

RCT_EXPORT_METHOD(setBarButtonItemTintColor:(NSString *)color) {
    [HBDGarden setBarButtonItemTintColor:color];
}

RCT_EXPORT_METHOD(setBarButtonItemTextSize:(NSUInteger)dp) {
    // only for android
}

RCT_EXPORT_METHOD(setLeftBarButtonItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    [garden setLeftBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    [garden setRightBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setTitleItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
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

@end
