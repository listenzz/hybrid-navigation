//
//  HBDDrawerController.h
//  NavigationHybrid
//
//  Created by Listen on 2018/1/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBDDrawerController : UIViewController

@property (nonatomic, strong, readonly) UIViewController *contentViewController;
@property (nonatomic, strong, readonly) UIViewController *menuViewController;

- (instancetype)initWithContentViewController:(UIViewController *)content menuViewController:(UIViewController *)menu;

- (void)openMenu;
- (void)closeMenu;
- (void)toggleMenu;
- (BOOL)isMenuOpened;

@end
