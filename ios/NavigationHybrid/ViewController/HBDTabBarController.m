//
//  HBDTabBarController.m
//  NavigationHybrid
//
//  Created by Listen on 2018/1/30.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDTabBarController.h"
#import "HBDUtils.h"

@interface HBDTabBarController ()

@end

@implementation HBDTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
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


@end
