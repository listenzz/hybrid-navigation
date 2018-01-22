//
//  HBDGardenModule.m
//
//  Created by Listen on 2017/11/26.
//

#import "HBDGardenModule.h"
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
    HBDViewController *vc = [self controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"leftBarButtonItem" forController:vc];
    [garden setLeftBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [self controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"rightBarButtonItem" forController:vc];
    [garden setRightBarButtonItem:item forController:vc];
}

RCT_EXPORT_METHOD(setTitleItem:(NSString *)navId sceneId:(NSString *)sceneId item:(NSDictionary *)item) {
    HBDViewController *vc = [self controllerForSceneId:sceneId];
    HBDGarden *garden = [[HBDGarden alloc] init];
    item = [self mergeItem:item key:@"titleItem" forController:vc];
    [garden setTitleItem:item forController:vc];
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    return [self controllerForSceneId:sceneId atController:controller];
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId atController:(UIViewController *)controller {
    HBDViewController *target;
    if ([controller isKindOfClass:[HBDViewController class]]) {
        HBDViewController *vc = (HBDViewController *)controller;
        if ([vc.sceneId isEqualToString:sceneId]) {
            target = vc;
        }
    }
    
    if (!target) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            target = [self controllerForSceneId:sceneId atController:presentedController];
        }
    }
    
    if (!target && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            target = [self controllerForSceneId:sceneId atController:child];
            if (target) {
                break;
            }
        }
    }
    return target;
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
