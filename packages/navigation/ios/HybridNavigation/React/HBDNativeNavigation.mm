//
//  HBDNativeNavigation.m
//  HybridNavigation
//
//  Created by 李生 on 2025/11/2.
//

#import "HBDNativeNavigation.h"

#import "HBDReactBridgeManager.h"
#import "HBDReactViewController.h"
#import "HBDAnimationObserver.h"

#import <React/RCTLog.h>
#import <ReactCommon/RCTTurboModule.h>

@interface HBDNativeNavigation () <RCTInvalidating>

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDNativeNavigation

+ (NSString *)moduleName { 
	return @"NativeNavigation";
}

+ (BOOL)requiresMainQueueSetup {
	return YES;
}

- (dispatch_queue_t)methodQueue {
	return dispatch_get_main_queue();
}

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

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
	return std::make_shared<facebook::react::NativeNavigationSpecJSI>(params);
}

- (nonnull facebook::react::ModuleConstants<JS::NativeNavigation::Constants::Builder>)constantsToExport { 
	JS::NativeNavigation::Constants::Builder::Input input = {
		ResultOK,
		ResultCancel,
		ResultBlock
	};
	// 这里用 typedConstants 工厂函数来生成 ModuleConstants
	return facebook::react::typedConstants<JS::NativeNavigation::Constants::Builder>(std::move(input));
}

- (nonnull facebook::react::ModuleConstants<JS::NativeNavigation::Constants::Builder>)getConstants {
	return [self constantsToExport];
}

- (void)startRegisterReactComponent {
	[self.bridgeManager startRegisterReactModule];
}

- (void)endRegisterReactComponent {
	[self.bridgeManager endRegisterReactModule];
}

- (void)registerReactComponent:(nonnull NSString *)appKey options:(nonnull NSDictionary *)options {
	[self.bridgeManager registerReactModule:appKey options:options];
}

- (void)signalFirstRenderComplete:(nonnull NSString *)sceneId {
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	if ([vc isKindOfClass:[HBDReactViewController class]]) {
		[(HBDReactViewController *)vc signalFirstRenderComplete];
	}
}

- (void)currentTab:(nonnull NSString *)sceneId callback:(nonnull RCTResponseSenderBlock)callback {
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	UITabBarController *tabs = vc.tabBarController;
	if (tabs) {
		callback(@[NSNull.null, @(tabs.selectedIndex)]);
	} else {
		callback(@[NSNull.null, @(-1)]);
	}
}

- (void)currentRoute:(nonnull RCTResponseSenderBlock)callback { 
	[self performSelector:@selector(currentRouteWithCallback:) withObject:callback];
}

- (void)routeGraph:(nonnull RCTResponseSenderBlock)callback {
	[self performSelector:@selector(routeGraphWithCallback:) withObject:callback];
}

- (void)findSceneIdByModuleName:(nonnull NSString *)moduleName callback:(nonnull RCTResponseSenderBlock)callback { 
	[self performSelector:@selector(findSceneIdWithParams:) withObject:@{
		@"callback": callback,
		@"moduleName": moduleName,
	}];
}

- (void)isStackRoot:(nonnull NSString *)sceneId callback:(nonnull RCTResponseSenderBlock)callback { 
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

- (void)dispatch:(nonnull NSString *)sceneId action:(nonnull NSString *)action params:(nonnull NSDictionary *)params callback:(nonnull RCTResponseSenderBlock)callback { 
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	if (!vc) {
		callback(@[NSNull.null, @NO]);
		RCTLogInfo(@"[Navigation] Can't find target scene for action: %@, maybe the scene is gone. \nextras: %@", action, params);
		return;
	}

	[self.bridgeManager handleNavigationWithViewController:vc action:action extras:params callback:(RCTResponseSenderBlock)callback];
}

- (void)setRoot:(nonnull NSDictionary *)layout sticky:(BOOL)sticky callback:(nonnull RCTResponseSenderBlock)callback { 
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

- (void)setResult:(nonnull NSString *)sceneId resultCode:(double)resultCode data:(nonnull NSDictionary *)data { 
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	[vc setResultCode:resultCode resultData:data];
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
