#import "HBDNavigationModule.h"

#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"
#import "HBDAnimationObserver.h"

#import <React/RCTLog.h>

@interface HBDNavigationModule () <RCTInvalidating>

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDNavigationModule

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(NavigationModule)

- (instancetype)init {
    if (self = [super init]) {
        _bridgeManager = [HBDReactBridgeManager get];
    }
    return self;
}

- (void)invalidate {
    RCTLogInfo(@"[Navigation] NavigationModule#invalidate");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[HBDAnimationObserver sharedObserver] invalidate];
    [self.bridgeManager invalidate];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{
        @"RESULT_OK": @(ResultOK),
        @"RESULT_CANCEL": @(ResultCancel),
        @"RESULT_BLOCK": @(ResultBlock)
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

RCT_EXPORT_METHOD(signalFirstRenderComplete:(NSString *) sceneId) {
    // RCTLogInfo(@"[Navigation] signalFirstRenderComplete sceneId:%@", sceneId);
    UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
    if ([vc isKindOfClass:[HBDReactViewController class]]) {
        [(HBDReactViewController *)vc signalFirstRenderComplete];
    }
}

RCT_EXPORT_METHOD(setRoot:(NSDictionary *)layout sticky:(BOOL)sticky callback:(RCTResponseSenderBlock)callback) {
    self.bridgeManager.viewHierarchyReady = NO;
    UIViewController *vc = [self.bridgeManager viewControllerWithLayout:layout];
    if (!vc) {
        @throw [[NSException alloc] initWithName:@"IllegalArgumentsException" reason:@"无法创建 ViewController" userInfo:@{ @"layout": layout }];
    }
    
    if (self.bridgeManager.didSetRoot) {
        self.bridgeManager.didSetRoot(@[NSNull.null, @NO]);
    }
    self.bridgeManager.didSetRoot = callback;
    self.bridgeManager.hasRootLayout = YES;
    
    [self.bridgeManager setRootViewController:vc];
}

RCT_EXPORT_METHOD(dispatch:(NSString *)sceneId action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback) {
    UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
    if (!vc) {
        callback(@[NSNull.null, @NO]);
        RCTLogInfo(@"[Navigation] Can't find target scene for action: %@, maybe the scene is gone. \nextras: %@", action, extras);
        return;
    }

    [self.bridgeManager handleNavigationWithViewController:vc action:action extras:extras callback:(RCTResponseSenderBlock)callback];
}

RCT_EXPORT_METHOD(currentTab:(NSString *)sceneId callback:(RCTResponseSenderBlock)callback) {
    UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
    UITabBarController *tabs = vc.tabBarController;
    if (tabs) {
        callback(@[NSNull.null, @(tabs.selectedIndex)]);
    } else {
        callback(@[NSNull.null, @(-1)]);
    }
}

RCT_EXPORT_METHOD(isStackRoot:(NSString *)sceneId callback:(RCTResponseSenderBlock)callback) {
    UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
    UINavigationController *nav = vc.navigationController;
    if (!nav) {
        callback(@[NSNull.null, @NO]);
        return;
    }

    NSArray *children = nav.childViewControllers;
    if (children.count == 0) {
        callback(@[NSNull.null, @NO]);
        return;
    }

    UIViewController *root = children[0];
    if ([root.sceneId isEqualToString:sceneId]) {
        callback(@[NSNull.null, @YES]);
        return;
    }

    callback(@[NSNull.null, @NO]);
}

RCT_EXPORT_METHOD(setResult:(NSString *)sceneId resultCode:(NSInteger)resultCode data:(NSDictionary *)data) {
    UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
    [vc setResultCode:resultCode resultData:data];
}

RCT_EXPORT_METHOD(findSceneIdByModuleName:(NSString *)moduleName callback:(RCTResponseSenderBlock)callback) {
    [self performSelector:@selector(findSceneIdWithParams:) withObject:@{
        @"callback": callback,
        @"moduleName": moduleName,
    }];
}

- (void)findSceneIdWithParams:(NSDictionary *)params {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(findSceneIdWithParams:) withObject:params afterDelay:0.016];
        return;
    }

    NSString *moduleName = params[@"moduleName"];
    RCTResponseSenderBlock callback = params[@"callback"];
    
    NSString *sceneId = [self findSceneIdByModuleName:moduleName];
    if (sceneId == nil) {
        RCTLogInfo(@"[Navigation] Can't find sceneId by : %@", moduleName);
        callback(@[NSNull.null, NSNull.null]);
        return;
    }
    
    RCTLogInfo(@"[Navigation] The sceneId found by %@ : %@", moduleName, sceneId);
    callback(@[[NSNull null], sceneId]);
}

- (NSString *)findSceneIdByModuleName:(NSString *)moduleName {
	UIWindow *keyWindow = RCTKeyWindow();
	if (keyWindow) {
		NSString *sceneId = [self findSceneIdByModuleName:moduleName withViewController:keyWindow.rootViewController];
		if (sceneId != nil) {
			RCTLogInfo(@"[Navigation] The sceneId found by %@ : %@", moduleName, sceneId);
			return sceneId;
		}
	}
	
	RCTLogInfo(@"[Navigation] KeyWindow NOT found.");
    
    return nil;
}

- (NSString *)findSceneIdByModuleName:(NSString *)moduleName withViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbd = (HBDViewController *)vc;
        if ([moduleName isEqualToString:hbd.moduleName]) {
            return hbd.sceneId;
        }
    }

	if (vc.presentedViewController && vc != vc.presentedViewController && !vc.presentedViewController.isBeingDismissed) {
        NSString *sceneId = [self findSceneIdByModuleName:moduleName withViewController:vc.presentedViewController];
        if (sceneId) {
            return sceneId;
        }
    }

    NSArray<UIViewController *> *children = vc.childViewControllers;
    if (children.count == 0) {
        return nil;
    }

    for (UIViewController *child in children) {
        NSString *sceneId = [self findSceneIdByModuleName:moduleName withViewController:child];
        if (sceneId) {
            return sceneId;
        }
    }

    return nil;
}

RCT_EXPORT_METHOD(currentRoute:(RCTResponseSenderBlock)callback) {
    [self performSelector:@selector(currentRouteWithCallback:) withObject:callback];
}

- (void)currentRouteWithCallback:(RCTResponseSenderBlock)callback {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(currentRouteWithCallback:) withObject:callback afterDelay:0.016];
        return;
    }

    HBDViewController *current = [self.bridgeManager primaryViewController];
    
    if (current) {
        callback(@[[NSNull null], @{
            @"moduleName": RCTNullIfNil(current.moduleName),
            @"sceneId": current.sceneId,
            @"presentingId": RCTNullIfNil(current.presentingSceneId),
            @"mode": [current hbd_mode],
            @"requestCode": @(current.requestCode),
        }]);
    } else {
        [self performSelector:@selector(currentRouteWithCallback:) withObject:callback afterDelay:0.016];
    }
}

RCT_EXPORT_METHOD(routeGraph:(RCTResponseSenderBlock)callback) {
    [self performSelector:@selector(routeGraphWithCallback:) withObject:callback];
}

- (void)routeGraphWithCallback:(RCTResponseSenderBlock)callback {
    if (!self.bridgeManager.isViewHierarchyReady) {
        [self performSelector:@selector(routeGraphWithCallback:) withObject:callback afterDelay:0.016];
        return;
    }

    NSArray *root = [self.bridgeManager routeGraph];
    if (root.count > 0) {
        callback(@[[NSNull null], root]);
    } else {
        [self performSelector:@selector(routeGraphWithCallback:) withObject:callback afterDelay:0.016];
    }
}

@end
