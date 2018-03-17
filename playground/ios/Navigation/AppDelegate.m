//
//  AppDelegate.m
//  Navigation
//
//  Created by Listen on 2017/11/18.
//  Copyright © 2017年 Listen. All rights reserved.
//

#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
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
//    UITabBarController *tabBarController = [[UITabBarController alloc] init];
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

@end
