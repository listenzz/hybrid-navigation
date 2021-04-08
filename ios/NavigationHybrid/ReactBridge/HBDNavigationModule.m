//
//  HBDNavigatorModule.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/19.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDNavigationModule.h"
#import <React/RCTLog.h>
#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"
#import "HBDModalViewController.h"

@interface Promiss : NSObject

@property(nonatomic, copy) RCTPromiseResolveBlock resolve;
@property(nonatomic, copy) RCTPromiseRejectBlock reject;

@end

@implementation Promiss


- (instancetype)initWithResolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter {
    if (self = [super init]) {
        _resolve = resolver;
        _reject = rejecter;
    }
    return self;
}

@end

@interface HBDNavigationModule()

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDNavigationModule

@synthesize bridge = _bridge;

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(NavigationHybrid)

- (instancetype)init {
    if (self = [super init]) {
        _bridgeManager = [HBDReactBridgeManager get];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReload) name:RCTBridgeWillReloadNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
}

- (void)handleReload {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{ @"RESULT_OK": @(ResultOK),
              @"RESULT_CANCEL": @(ResultCancel)
              };
}

RCT_EXPORT_METHOD(startRegisterReactComponent) {
    [self.bridgeManager startRegisterReactModule];
}

RCT_EXPORT_METHOD(endRegisterReactComponent) {
    [self.bridgeManager endRegisterReactModule];
}

RCT_EXPORT_METHOD(registerReactComponent:(NSString *)appKey options:(NSDictionary *)options) {
    [self.bridgeManager registerReactModule:appKey options:options];
}

RCT_EXPORT_METHOD(signalFirstRenderComplete:(NSString *)sceneId) {
    // RCTLogInfo(@"signalFirstRenderComplete sceneId:%@",sceneId);
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    if ([vc isKindOfClass:[HBDReactViewController class]]) {
        [(HBDReactViewController *)vc signalFirstRenderComplete];
    }
}

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout sticky:(BOOL)sticky tag:(NSNumber * __nonnull)tag) {
    self.bridgeManager.viewHierarchyReady = NO;
    UIViewController *vc = [self.bridgeManager controllerWithLayout:layout];
    if (vc) {
        self.bridgeManager.hasRootLayout = YES;
        [self.bridgeManager setRootViewController:vc withTag:tag];
    }
}

RCT_EXPORT_METHOD(dispatch:(NSString *)sceneId action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    if (vc) {
        [self.bridgeManager handleNavigationWithViewController:vc action:action extras:extras resolver:resolve rejecter:reject];
    } else {
        resolve(@(NO));
        RCTLogWarn(@"Can't find target scene for action:%@, maybe the scene is gone. \nextras: %@", action, extras);
    }
}

RCT_EXPORT_METHOD(currentTab:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabs = vc.tabBarController;
    if (tabs) {
        resolve(@(tabs.selectedIndex));
    } else {
        resolve(@(-1));
    }
}

RCT_EXPORT_METHOD(isNavigationRoot:(NSString *)sceneId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        NSArray *children = nav.childViewControllers;
        if (children.count > 0) {
            HBDReactViewController *vc = children[0];
            if ([vc.sceneId isEqualToString:sceneId]) {
                resolve(@YES);
                return;
            }
        }
    }
    resolve(@NO);
}

RCT_EXPORT_METHOD(setResult:(NSString *)sceneId resultCode:(NSInteger)resultCode data:(NSDictionary *)data) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(findSceneIdByModuleName:(NSString *)moduleName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    Promiss *promiss = [[Promiss alloc] initWithResolver:resolve rejecter:reject];
    [self performSelector:@selector(findSceneIdWithParams:) withObject:@{
        @"promiss": promiss,
        @"moduleName": moduleName,
    }];
}

- (void)findSceneIdWithParams:(NSDictionary *)params {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(findSceneIdWithParams:) withObject:params afterDelay:0.016];
        return;
    }
    
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    NSString *sceneId = nil;
    NSInteger index = application.windows.count - 1;
    
    NSString *moduleName = params[@"moduleName"];
    Promiss *promiss = params[@"promiss"];
    
    while (index > -1 && sceneId == nil) {
        UIWindow *window = application.windows[index];
        sceneId = [self findeSceneIdByModuleName:moduleName withViewController:window.rootViewController];
        index--;
    }
    RCTLogInfo(@"通过 %@ 找到的 sceneId:%@", moduleName, sceneId);
    promiss.resolve(RCTNullIfNil(sceneId));
}

- (NSString *)findeSceneIdByModuleName:(NSString *)moduleName withViewController:(UIViewController *)vc {
    NSString *sceneId = nil;
    
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbd = (HBDViewController *)vc;
        if ([moduleName isEqualToString:hbd.moduleName]) {
            sceneId = hbd.sceneId;
        }
    }
    
    if (sceneId == nil) {
        if (vc.presentedViewController && !vc.presentedViewController.isBeingDismissed) {
            sceneId = [self findeSceneIdByModuleName:moduleName withViewController:vc.presentedViewController];
        }
    }
    
    if (sceneId == nil) {
        NSArray<UIViewController *> *children = vc.childViewControllers;
        NSInteger count = children.count;
        if (count > 0) {
            NSInteger index = count - 1;
            while (index > -1 && sceneId == nil) {
                UIViewController *child = children[index];
                sceneId = [self findeSceneIdByModuleName:moduleName withViewController:child];
                index--;
            }
        }
    }
    
    return sceneId;
}

RCT_EXPORT_METHOD(currentRoute:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    Promiss *promiss = [[Promiss alloc] initWithResolver:resolve rejecter:reject];
    [self performSelector:@selector(currentRouteWithPromiss:) withObject:promiss];
}

- (void)currentRouteWithPromiss:(Promiss *)promiss {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(currentRouteWithPromiss:) withObject:promiss afterDelay:0.016];
        return;
    }
    
    HBDViewController *current = [self.bridgeManager primaryViewController];
    if (current) {
        promiss.resolve(@{ @"moduleName": current.moduleName, @"sceneId": current.sceneId, @"mode": [current hbd_mode] });
    } else {
        [self performSelector:@selector(currentRouteWithPromiss:) withObject:promiss afterDelay:0.016];
    }
}

RCT_EXPORT_METHOD(routeGraph:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    Promiss *promiss = [[Promiss alloc] initWithResolver:resolve rejecter:reject];
    [self performSelector:@selector(routeGraphWithPromiss:) withObject:promiss];
}

- (void)routeGraphWithPromiss:(Promiss*)promiss {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(routeGraphWithPromiss:) withObject:promiss afterDelay:0.016];
        return;
    }
    
    NSArray *root = [self.bridgeManager routeGraph];
    if (root.count > 0) {
        promiss.resolve(root);
    } else {
        [self performSelector:@selector(routeGraphWithPromiss:) withObject:promiss afterDelay:0.016];
    }
}

@end
