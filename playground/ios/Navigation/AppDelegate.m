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
#import <NavigationHybrid/NavigationHybrid.h>
#import "OneNativeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"playground/index" fallbackResource:nil];
    [[HBDReactBridgeManager sharedInstance] installWithBundleURL:jsCodeLocation launchOptions:launchOptions];
    
    // register native modules
    [[HBDReactBridgeManager sharedInstance] registerNativeModule:@"OneNative" forController:[OneNativeViewController class]];
    
    // build root
//    HBDViewController *navigation = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:@"Navigation" props:nil options:nil];
//    HBDNavigationController *navigationNav = [[HBDNavigationController alloc] initWithRootViewController:navigation];
//    HBDViewController *options = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:@"Options" props:nil options:nil];
//    HBDNavigationController *optionsNav = [[HBDNavigationController alloc] initWithRootViewController:options];
//
//    HBDTabBarController *tabBarController = [[HBDTabBarController alloc] init];
//    [tabBarController setViewControllers:@[navigationNav, optionsNav]];
//
//    HBDViewController *menuController = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:@"Menu" props:nil options:nil];
//    HBDDrawerController *drawerController = [[HBDDrawerController alloc] initWithContentViewController:tabBarController menuViewController:menuController];
//    drawerController.maxDrawerWidth = 280;
//
//    UIViewController *rootViewController = drawerController;
    
    UIStoryboard *storyboard =  [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];

    // set root
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
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

@end
