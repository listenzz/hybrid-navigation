#import "HBDGardenModule.h"

#import "HBDReactBridgeManager.h"
#import "HBDTabBarController.h"
#import "GlobalStyle.h"

#import <React/RCTLog.h>

@interface HBDGardenModule ()

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@end

@implementation HBDGardenModule

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(GardenModule)

- (instancetype)init {
    if (self = [super init]) {
        _bridgeManager = [HBDReactBridgeManager get];
    }
    return self;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{@"TOOLBAR_HEIGHT": @(44)};
}

RCT_EXPORT_METHOD(setStyle:(NSDictionary *) style) {
    [GlobalStyle createWithOptions:style];
}

RCT_EXPORT_METHOD(setTitleItem:(NSString *) sceneId item:(NSDictionary *) item) {
    HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
    if (vc) {
        [vc updateNavigationBarOptions:@{@"titleItem": RCTNullIfNil(item)}];
    }
}

RCT_EXPORT_METHOD(setLeftBarButtonItem:(NSString *) sceneId item:(NSDictionary *__nullable) item) {
    HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
    if (vc) {
        [vc updateNavigationBarOptions:@{@"leftBarButtonItem": RCTNullIfNil(item)}];
    }
}

RCT_EXPORT_METHOD(setRightBarButtonItem:(NSString *) sceneId item:(NSDictionary *__nullable) item) {
    HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
    if (vc) {
        [vc updateNavigationBarOptions:@{@"rightBarButtonItem": RCTNullIfNil(item)}];
    }
}

RCT_EXPORT_METHOD(setLeftBarButtonItems:(NSString *) sceneId item:(NSArray *__nullable) items) {
    HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
    if (vc) {
        [vc updateNavigationBarOptions:@{@"leftBarButtonItems": RCTNullIfNil(items)}];
    }
}

RCT_EXPORT_METHOD(setRightBarButtonItems:(NSString *) sceneId item:(NSArray *__nullable) items) {
    HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
    if (vc) {
        [vc updateNavigationBarOptions:@{@"rightBarButtonItems": RCTNullIfNil(items)}];
    }
}

RCT_EXPORT_METHOD(updateOptions:(NSString *) sceneId item:(NSDictionary *) options) {
    RCTLogInfo(@"[Navigator] updateNavigationBarOptions: %@", options);
    HBDViewController *vc = [self viewControllerWithSceneId:sceneId];
    if (vc) {
        [vc updateNavigationBarOptions:options];
    }
}

RCT_EXPORT_METHOD(updateTabBar:(NSString *) sceneId item:(NSDictionary *) item) {
    RCTLogInfo(@"[Navigator] updateTabBar: %@", item);
    UIViewController *vc = [self.bridgeManager viewControllerWithSceneId:sceneId];
    UITabBarController *tabBarVC = [self tabBarControllerWithViewController:vc];
    if (tabBarVC && [tabBarVC isKindOfClass:[HBDTabBarController class]]) {
        [((HBDTabBarController *)tabBarVC) updateTabBar:item];
    }
}

RCT_EXPORT_METHOD(setTabItem:(NSString *) sceneId options:(NSArray<NSDictionary *> *) options) {
    RCTLogInfo(@"[Navigator] setTabItem: %@", options);
    UIViewController *vc = [self.bridgeManager viewControllerWithSceneId:sceneId];
    UITabBarController *tabBarController = [self tabBarControllerWithViewController:vc];
    if ([tabBarController isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabBarVC = (HBDTabBarController *) tabBarController;
        [tabBarVC setTabItem:options];
    }
}

RCT_EXPORT_METHOD(setMenuInteractive:(NSString *) sceneId enabled:(BOOL) enabled) {
    UIViewController *vc = [self.bridgeManager viewControllerWithSceneId:sceneId];
    HBDDrawerController *drawer = [vc drawerController];
    if (drawer) {
        drawer.menuInteractive = enabled;
    }
}

- (HBDViewController *)viewControllerWithSceneId:(NSString *)sceneId {
    UIViewController *vc = [self.bridgeManager viewControllerWithSceneId:sceneId];
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
