//
//  HBDTabBarController.m
//  NavigationHybrid
//
//  Created by Listen on 2018/1/30.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDTabBarController.h"
#import "HBDReactViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import <React/RCTEventEmitter.h>

@interface HBDTabBarController () <UITabBarControllerDelegate>

@end

@implementation HBDTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    self.delegate = self;
    self.intercepted = YES;
}

- (void)updateTabBar:(NSDictionary *)options {
    UITabBar *tabBar = self.tabBar;
    
    NSString *tabBarItemColor = options[@"tabBarItemColor"];
    if (tabBarItemColor) {
        tabBar.tintColor = [HBDUtils colorWithHexString:tabBarItemColor];
        NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
        if (tabBarUnselectedItemColor) {
            if (@available(iOS 10.0, *)) {
                tabBar.unselectedItemTintColor = [HBDUtils colorWithHexString:tabBarUnselectedItemColor];
            }
        }
    }
    
    NSString *tabBarColor = [options objectForKey:@"tabBarColor"];
    if (tabBarColor) {
        [tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]]];
    }
    
    NSDictionary *tabBarShadowImage = options[@"tabBarShadowImage"];
    if (tabBarShadowImage && ![tabBarShadowImage isEqual:NSNull.null]) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = tabBarShadowImage[@"image"];
        NSString *color = tabBarShadowImage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        tabBar.shadowImage = image;
    }
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    UIViewController *selectedVC = self.selectedViewController;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)selectedVC;
        selectedVC = nav.viewControllers[0];
    }
    
    HBDReactViewController *selectedReactVC = nil;
    if ([selectedVC isKindOfClass:[HBDReactViewController class]]) {
        selectedReactVC = (HBDReactViewController *)selectedVC;
    }
    
    if (!selectedReactVC || !self.intercepted) {
        return YES;
    }
    
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        viewController = nav.viewControllers[0];
    }
    
    HBDReactViewController *reactVC = nil;
    if ([viewController isKindOfClass:[HBDReactViewController class]]) {
        reactVC = (HBDReactViewController *)viewController;
    }
    
    RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"NavigationHybrid"];
    [emitter sendEventWithName:@"SWITCH_TAB" body:@{
            @"from": selectedReactVC.moduleName ?: NSNull.null,
            @"sceneId": selectedReactVC.sceneId,
            @"moduleName": reactVC.moduleName?: NSNull.null,
            @"index": @(index)
        }];
    
    return NO;
}

@end
