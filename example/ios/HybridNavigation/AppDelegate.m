#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLinkingManager.h>
#import <React/RCTLog.h>
#import <HybridNavigation/HybridNavigation.h>
#import <ToastHybrid/ToastHybrid.h>

#import "NativeViewController.h"

#if RCT_DEV
#import <React/RCTDevLoadingView.h>
#endif

@interface AppDelegate () <HBDReactBridgeManagerDelegate, HostViewProvider>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    RCTSetLogThreshold(RCTLogLevelInfo);
    
    // 设置 toast 的 hostView, 可以不设置
    [ToastConfig sharedConfig].hostViewProvider = self;
    
    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
    [[HBDReactBridgeManager get] installWithBridge:bridge];
    
    // register native modules
    [[HBDReactBridgeManager get] registerNativeModule:@"NativeModule" forViewController:[NativeViewController class]];
   
#if RCT_DEV
    [[HBDReactBridgeManager get].bridge moduleForClass:[RCTDevLoadingView class]];
#endif

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"example/index"];
#else
    return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager {
    
}

// iOS 9.x or newer
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [RCTLinkingManager application:application openURL:url options:options];
}

//// universal links
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
//    return [RCTLinkingManager application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
//}

- (UIView *)hostView {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    return [self controller:controller].view;
}

- (UIViewController *)controller:(UIViewController *)controller {
    UIViewController *presentedController = controller.presentedViewController;
    if (presentedController && ![presentedController isBeingDismissed]) {
        return [self controller:presentedController];
    } else if ([controller isKindOfClass:[HBDDrawerController class]]) {
        HBDDrawerController *drawer = (HBDDrawerController *)controller;
        if ([drawer isMenuOpened]) {
            return drawer;
        } else {
            return [self controller:drawer.contentController];
        }
    } else if ([controller isKindOfClass:[HBDTabBarController class]]) {
        HBDTabBarController *tabs = (HBDTabBarController *)controller;
        return [self controller:tabs.selectedViewController];
    }
    return controller;
}

@end
