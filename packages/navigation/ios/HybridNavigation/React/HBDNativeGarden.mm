#import "HBDNativeGarden.h"

#import "HBDReactBridgeManager.h"
#import "HBDTabBarController.h"
#import "GlobalStyle.h"
#import "HBDUtils.h"

#import <React/RCTLog.h>

@interface HBDNativeGarden ()

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDNativeGarden

+ (NSString *)moduleName { 
	return @"HBDNativeGarden";
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

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
	return std::make_shared<facebook::react::NativeGardenSpecJSI>(params);
}

- (nonnull facebook::react::ModuleConstants<JS::NativeGarden::Constants::Builder>)constantsToExport { 
	JS::NativeGarden::Constants::Builder::Input input = {
		44
	};
	return facebook::react::typedConstants<JS::NativeGarden::Constants::Builder>(std::move(input));
}

- (nonnull facebook::react::ModuleConstants<JS::NativeGarden::Constants::Builder>)getConstants { 
	return [self constantsToExport];
}

- (void)setLeftBarButtonItem:(nonnull NSString *)sceneId item:(NSDictionary * _Nullable)item { 
	HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
	if (vc) {
		[vc updateNavigationBarOptions:@{@"leftBarButtonItem": RCTNullIfNil(item)}];
	}
}


- (void)setLeftBarButtonItems:(nonnull NSString *)sceneId items:(NSArray * _Nullable)items { 
	HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
	if (vc) {
		[vc updateNavigationBarOptions:@{@"leftBarButtonItems": RCTNullIfNil(items)}];
	}
}


- (void)setMenuInteractive:(nonnull NSString *)sceneId enabled:(BOOL)enabled { 
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	HBDDrawerController *drawer = [vc drawerController];
	if (drawer) {
		drawer.menuInteractive = enabled;
	}
}


- (void)setRightBarButtonItem:(nonnull NSString *)sceneId item:(NSDictionary * _Nullable)item { 
	HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
	if (vc) {
		[vc updateNavigationBarOptions:@{@"rightBarButtonItem": RCTNullIfNil(item)}];
	}
}


- (void)setRightBarButtonItems:(nonnull NSString *)sceneId items:(NSArray * _Nullable)items { 
	HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
	if (vc) {
		[vc updateNavigationBarOptions:@{@"rightBarButtonItems": RCTNullIfNil(items)}];
	}
}


- (void)setStyle:(nonnull NSDictionary *)style { 
	[GlobalStyle createWithOptions:style];
}


- (void)setTabItem:(nonnull NSString *)sceneId item:(nonnull NSArray *)item { 
	RCTLogInfo(@"[Navigation] setTabItem: %@", item);
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
	if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
		HBDTabBarController *tabBarVC = (HBDTabBarController *)tabBarController;
		[tabBarVC setTabItem:item];
	}
}


- (void)setTitleItem:(nonnull NSString *)sceneId item:(nonnull NSDictionary *)item { 
	HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
	if (vc) {
		[vc updateNavigationBarOptions:@{@"titleItem": RCTNullIfNil(item)}];
	}
}


- (void)updateOptions:(nonnull NSString *)sceneId options:(nonnull NSDictionary *)options { 
	RCTLogInfo(@"[Navigation] updateNavigationBarOptions: %@", options);
	HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
	if (vc) {
		[vc updateNavigationBarOptions:options];
	}
}


- (void)updateTabBar:(nonnull NSString *)sceneId item:(nonnull NSDictionary *)item { 
	RCTLogInfo(@"[Navigation] updateTabBar: %@", item);
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	UITabBarController *tabBarVC = [self tabBarControllerWithViewController:vc];
	if (tabBarVC && [tabBarVC isKindOfClass:[HBDTabBarController class]]) {
		[((HBDTabBarController *)tabBarVC) updateTabBar:item];
	}
}

- (HBDViewController *)viewControllerWithSceneId:(NSString *)sceneId {
	UIViewController *vc = [self.bridgeManager viewControllerBySceneId:sceneId];
	if ([vc isKindOfClass:[HBDViewController class]]) {
		return (HBDViewController *)vc;
	}
	return nil;
}

- (UITabBarController *)tabBarControllerWithViewController:(UIViewController *)vc {
	if ([vc isKindOfClass:[UITabBarController class]]) {
		return (UITabBarController *)vc;
	} else {
		return vc.tabBarController;
	}
}

@end
