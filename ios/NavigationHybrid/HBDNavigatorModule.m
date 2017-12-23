//
//  HBDNavigatorModule.m
//  Pods
//
//  Created by Listen on 2017/11/19.
//

#import "HBDNavigatorModule.h"
#import <React/RCTLog.h>
#import "HBDReactBridgeManager.h"
#import "HBDNavigator.h"
#import "HBDReactViewController.h"

@interface HBDNavigatorModule()

@end

@implementation HBDNavigatorModule

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(NavigationHybrid)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{ @"RESULT_OK": @(RESULT_OK),
              @"RESULT_CANCEL": @(RESULT_CANCEL)
              };
}

- (NSArray<NSString *> *)supportedEvents {
    return @[ON_COMPONENT_RESULT_EVENT,
             ON_BAR_BUTTON_ITEM_CLICK_EVENT
             ];
}

RCT_EXPORT_METHOD(startRegisterReactComponent) {
    [[HBDReactBridgeManager instance] startRegisterReactModule];
}

RCT_EXPORT_METHOD(endRegisterReactComponent) {
    [[HBDReactBridgeManager instance] endRegisterReactModule];
}

RCT_EXPORT_METHOD(registerReactComponent:(NSString *)appKey options:(NSDictionary *)options) {
    [[HBDReactBridgeManager instance] registerReactModule:appKey options:options];
}

RCT_EXPORT_METHOD(signalFirstRenderComplete:(NSString *)navId sceneId:(NSString *)sceneId) {
    NSLog(@"signalFirstRenderComplete navId:%@ sceneId:%@", navId, sceneId);
}

RCT_EXPORT_METHOD(push:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator pushModule:moduleName props:props options:options animated:animated];
}

RCT_EXPORT_METHOD(pop:(NSString *)navId sceneId:(NSString *)sceneId animated:(BOOL) animated) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator popAnimated:animated];
}

RCT_EXPORT_METHOD(popTo:(NSString *)navId sceneId:(NSString *)sceneId targetId:(NSString *)targetId animated:(BOOL) animated) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator popToScene:targetId animated:animated];
}

RCT_EXPORT_METHOD(popToRoot:(NSString *)navId sceneId:(NSString *)sceneId animated:(BOOL) animated) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator popToRootAnimated:animated];
}

RCT_EXPORT_METHOD(isRoot:(NSString *)navId sceneId:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    if (navigator) {
        NSArray *children = navigator.navigationController.childViewControllers;
        if (children.count > 0) {
            HBDReactViewController *vc = children[0];
            if ([vc.sceneId isEqualToString:sceneId]) {
                resolve(@YES);
            } else {
                resolve(@NO);
            }
        }
    }
}

RCT_EXPORT_METHOD(replace:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator replaceModule:moduleName props:props options:options];
}

RCT_EXPORT_METHOD(replaceToRoot:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator replaceToRootModule:moduleName props:props options:options];
}

RCT_EXPORT_METHOD(present:(NSString *)navId sceneId:(NSString *)sceneId moduleName:(NSString *)moduleName requestCode:(NSInteger)requestCode props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL)animated) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator presentModule:moduleName requestCode:requestCode props:props options:options animated:animated];
}

RCT_EXPORT_METHOD(setResult:(NSString *)navId sceneId:(NSString *)sceneId resultCode:(NSInteger)resultCode data:(NSDictionary *)data) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator setResultCode:resultCode data:data];
}

RCT_EXPORT_METHOD(dismiss:(NSString *)navId sceneId:(NSString *)sceneId animated:(BOOL)animated) {
    HBDNavigator *navigator = [self navigatorForNavId:navId];
    [navigator dismissAnimated:animated];
}

- (HBDNavigator *)navigatorForNavId:(NSString *)navId {
    HBDNavigator *navigator = [HBDNavigator navigatorForId:navId];
    if (!navigator) {
        NSLog(@"找不到对应的 navigator，似乎哪个地方出错了");
    }
    return navigator;
}


@end
