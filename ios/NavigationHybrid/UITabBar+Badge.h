//
//  UITabBar+Badge.h
//  NavigationHybrid
//
//  Created by Listen on 2018/7/5.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (Badge)

- (void)showRedPointAtIndex:(NSInteger)index;
- (void)hideRedPointAtIndex:(NSInteger)index;
@end
