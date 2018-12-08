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

- (void)updateTabBar:(NSDictionary *)options;

@end
