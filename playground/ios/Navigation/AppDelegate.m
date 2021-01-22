//
//  AppDelegate.m
//  Navigation
//
//  Created by Listen on 2017/11/18.
//  Copyright © 2017年 Listen. All rights reserved.
//

#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLinkingManager.h>
#import <React/RCTBridgeModule.h>
#import <NavigationHybrid/NavigationHybrid.h>
#import <ToastHybrid/ToastHybrid.h>
#import <React/RCTLog.h>

#import "OneNativeViewController.h"
#import "NativeModalViewController.h"

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
    
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"playground/index" fallbackResource:nil];
    [[HBDReactBridgeManager get] installWithBundleURL:jsCodeLocation launchOptions:launchOptions];
    
    // register native modules
    [[HBDReactBridgeManager get] registerNativeModule:@"OneNative" forController:[OneNativeViewController class]];
    [[HBDReactBridgeManager get] registerNativeModule:@"NativeModal" forController:[NativeModalViewController class]];
    
#if RCT_DEV
    [[HBDReactBridgeManager get].bridge moduleForClass:[RCTDevLoadingView class]];
#endif

    UIStoryboard *storyboard =  [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager {
    
}

//// iOS 8.x or older
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [RCTLinkingManager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
//
// iOS 9.x or newer
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//    return [RCTLinkingManager application:application openURL:url options:options];
//}

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
