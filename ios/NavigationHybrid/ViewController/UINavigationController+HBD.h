//
//  UINavigationController+HBD.h
//  NavigationHybrid
//
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (HBD)

- (void)replaceViewController:(UIViewController *)controller animated:(BOOL)animated;

- (void)replaceViewController:(UIViewController *)controller target:(UIViewController *)target animated:(BOOL)animated;

- (void)replaceToRootViewController:(UIViewController *)controller animated:(BOOL)animated;

@end
