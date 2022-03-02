//
//  UITabBar+Badge.h
//  HybridNavigation
//
//  Created by Listen on 2018/7/5.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (DotBadge)

- (void)showDotBadgeAtIndex:(NSInteger)index;

- (void)hideDotBadgeAtIndex:(NSInteger)index;

@end
