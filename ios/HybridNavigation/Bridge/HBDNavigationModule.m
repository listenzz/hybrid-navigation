#import "HBDNavigationModule.h"

#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"

#import <React/RCTLog.h>

@interface Promise : NSObject

@property(nonatomic, copy) RCTPromiseResolveBlock resolve;
@property(nonatomic, copy) RCTPromiseRejectBlock reject;

@end

@implementation Promise


- (instancetype)initWithResolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter {
    if (self = [super init]) {
        _resolve = resolver;
        _reject = rejecter;
    }
    return self;
}

@end

@interface HBDNavigationModule ()

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDNavigationModule

@synthesize bridge = _bridge;

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(NavigationModule)

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
    return @{@"RESULT_OK": @(ResultOK),
            @"RESULT_CANCEL": @(ResultCancel)
    };
}

RCT_EXPORT_METHOD(startRegisterReactComponent) {
    [self.bridgeManager startRegisterReactModule];
}

RCT_EXPORT_METHOD(endRegisterReactComponent) {
    [self.bridgeManager endRegisterReactModule];
}

RCT_EXPORT_METHOD(registerReactComponent:
    (NSString *) appKey options:
    (NSDictionary *) options) {
    [self.bridgeManager registerReactModule:appKey options:options];
}

RCT_EXPORT_METHOD(signalFirstRenderComplete:(NSString *) sceneId) {
    // RCTLogInfo(@"[Navigator] signalFirstRenderComplete sceneId:%@", sceneId);
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    if ([vc isKindOfClass:[HBDReactViewController class]]) {
        [(HBDReactViewController *) vc signalFirstRenderComplete];
    }
}

RCT_EXPORT_METHOD(setRoot:(NSDictionary *) layout sticky:(BOOL) sticky tag:(NSNumber *__nonnull) tag) {
    self.bridgeManager.viewHierarchyReady = NO;
    UIViewController *vc = [self.bridgeManager controllerWithLayout:layout];
    if (vc) {
        self.bridgeManager.hasRootLayout = YES;
        [self.bridgeManager setRootViewController:vc withTag:tag];
    }
}

RCT_EXPORT_METHOD(dispatch:(NSString *) sceneId action:(NSString *) action extras:(NSDictionary *) extras resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    if (vc) {
        [self.bridgeManager handleNavigationWithViewController:vc action:action extras:extras resolver:resolve rejecter:reject];
    } else {
        resolve(@(NO));
        RCTLogWarn(@"[Navigator] Can't find target scene for action: %@, maybe the scene is gone. \nextras: %@", action, extras);
    }
}

RCT_EXPORT_METHOD(currentTab:(NSString *) sceneId resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UITabBarController *tabs = vc.tabBarController;
    if (tabs) {
        resolve(@(tabs.selectedIndex));
    } else {
        resolve(@(-1));
    }
}

RCT_EXPORT_METHOD(isStackRoot:(NSString *) sceneId resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        NSArray *children = nav.childViewControllers;
        if (children.count > 0) {
            HBDReactViewController *reactViewController = children[0];
            if ([reactViewController.sceneId isEqualToString:sceneId]) {
                resolve(@YES);
                return;
            }
        }
    }
    resolve(@NO);
}

RCT_EXPORT_METHOD(setResult:(NSString *) sceneId resultCode:(NSInteger) resultCode data:(NSDictionary *) data) {
    UIViewController *vc = [self.bridgeManager controllerForSceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(findSceneIdByModuleName:(NSString *) moduleName resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    Promise *promise = [[Promise alloc] initWithResolver:resolve rejecter:reject];
    [self performSelector:@selector(findSceneIdWithParams:) withObject:@{
            @"promise": promise,
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
    NSString *moduleName = params[@"moduleName"];
    Promise *promise = params[@"promise"];

    NSUInteger index = application.windows.count;
    while (index > 0 && sceneId == nil) {
        UIWindow *window = application.windows[index - 1];
        sceneId = [self findSceneIdByModuleName:moduleName withViewController:window.rootViewController];
        index--;
    }
    RCTLogInfo(@"[Navigator] The sceneId found by %@ : %@", moduleName, sceneId);
    promise.resolve(RCTNullIfNil(sceneId));
}

- (NSString *)findSceneIdByModuleName:(NSString *)moduleName withViewController:(UIViewController *)vc {
    NSString *sceneId = nil;

    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbd = (HBDViewController *) vc;
        if ([moduleName isEqualToString:hbd.moduleName]) {
            sceneId = hbd.sceneId;
        }
    }

    if (sceneId == nil) {
        if (vc.presentedViewController && !vc.presentedViewController.isBeingDismissed) {
            sceneId = [self findSceneIdByModuleName:moduleName withViewController:vc.presentedViewController];
        }
    }

    if (sceneId == nil) {
        NSArray<UIViewController *> *children = vc.childViewControllers;
        NSUInteger count = children.count;
        if (count > 0) {
            NSUInteger index = count;
            while (index > 0 && sceneId == nil) {
                UIViewController *child = children[index - 1];
                sceneId = [self findSceneIdByModuleName:moduleName withViewController:child];
                index--;
            }
        }
    }

    return sceneId;
}

RCT_EXPORT_METHOD(currentRoute:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    Promise *promise = [[Promise alloc] initWithResolver:resolve rejecter:reject];
    [self performSelector:@selector(currentRouteWithPromise:) withObject:promise];
}

- (void)currentRouteWithPromise:(Promise *)promise {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(currentRouteWithPromise:) withObject:promise afterDelay:0.016];
        return;
    }

    HBDViewController *current = [self.bridgeManager primaryViewController];
    if (current) {
        promise.resolve(@{@"moduleName": RCTNullIfNil(current.moduleName), @"sceneId": current.sceneId, @"mode": [current hbd_mode]});
    } else {
        [self performSelector:@selector(currentRouteWithPromise:) withObject:promise afterDelay:0.016];
    }
}

RCT_EXPORT_METHOD(routeGraph:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    Promise *promise = [[Promise alloc] initWithResolver:resolve rejecter:reject];
    [self performSelector:@selector(routeGraphWithPromise:) withObject:promise];
}

- (void)routeGraphWithPromise:(Promise *)promise {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(routeGraphWithPromise:) withObject:promise afterDelay:0.016];
        return;
    }

    NSArray *root = [self.bridgeManager routeGraph];
    if (root.count > 0) {
        promise.resolve(root);
    } else {
        [self performSelector:@selector(routeGraphWithPromise:) withObject:promise afterDelay:0.016];
    }
}

@end
