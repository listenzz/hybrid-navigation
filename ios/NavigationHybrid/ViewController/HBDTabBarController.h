//
//  HBDTabBarController.h
//  NavigationHybrid
//
//  Created by Listen on 2018/1/30.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBDTabBarController : UITabBarController

@property (nonatomic, assign) BOOL intercepted;

- (instancetype)initWithTabBarOptions:(NSDictionary *)options;

- (void)updateTabBar:(NSDictionary *)options;

- (void)setBadgeText:(NSString *)text atIndex:(NSInteger)index;

- (void)setRedPointVisible:(BOOL)visible atIndex:(NSInteger)index;

- (void)updateTabBarItem:(NSDictionary *)tabItem atIndex:(NSInteger)index;

@end
