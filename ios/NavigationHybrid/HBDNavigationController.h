//
//  HBDNavigationController.h
//  NavigationHybrid
//
//  Created by Listen on 2017/12/16.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBDNavigationController : UINavigationController

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;

- (void)updateNavigationBarColorForViewController:(UIViewController *)vc;

- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc;

@end
