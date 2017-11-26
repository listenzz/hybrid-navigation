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

RCT_EXPORT_METHOD(setLeftBarButtonItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDReactViewController *vc = [self controllerForNavId:navId sceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    [garden setLeftBarButtonItem:item forController:vc];
    NSLog(@"setLeftBarButtonItem--------------------");
}

- (HBDReactViewController *)controllerForNavId:(NSString *)navId sceneId:(NSString *)sceneId {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    UIViewController *vc = navigator.navigationController.topViewController;
    if ([vc isKindOfClass:[HBDReactViewController class]]) {
        HBDReactViewController *hbdvc = (HBDReactViewController *)vc;
        if ([hbdvc.sceneId isEqualToString:sceneId]) {
            return hbdvc;
        }
    }
    RCTLogWarn(@"top controller 不是要找的 controller，似乎哪个地方出错了");
    return nil;
}

- (HBDNavigator *)navigatorForNavId:(NSString *)navId {
    HBDNavigator *navigator = [[HBDReactBridgeManager instance] navigatorForNavId:navId];
    if (!navigator) {
        RCTLogWarn(@"找不到对应的 navigator，似乎哪个地方出错了");
    }
    return navigator;
}

@end
