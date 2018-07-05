//
//  UITabBar+Badge.m
//  NavigationHybrid
//
//  Created by Listen on 2018/7/5.
//  Copyright © 2018年 Listen. All rights reserved.
//
#import "UITabBar+Badge.h"

@implementation UITabBar (Badge)

- (void)showRedPointAtIndex:(NSInteger)index {
    [self hideRedPointAtIndex:index];
    //label为小红点，并设置label属性
    UILabel *label = [[UILabel alloc]init];
    label.tag = 1000+index;
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    if (@available(iOS 10.0, *)) {
        label.backgroundColor = [UITabBarItem appearance].badgeColor ?: [UIColor colorWithRed:1 green:58.0/255.0 blue:47./255. alpha:1];
    } else {
        label.backgroundColor = [UIColor colorWithRed:1 green:58.0/255.0 blue:47./255. alpha:1];
    }
    CGRect tabFrame = self.frame;
   
    //计算小红点的X值，根据第index控制器，小红点在每个tabbar按钮的中部偏移0.1，即是每个按钮宽度的0.6倍
    CGFloat percentX = (index+0.6);
    CGFloat tabBarButtonW = CGRectGetWidth(tabFrame)/self.items.count;
    CGFloat x = percentX*tabBarButtonW;
    CGFloat y = 0.1*CGRectGetHeight(tabFrame);
    //10为小红点的高度和宽度
    label.frame = CGRectMake(x, y, 10, 10);
    
    [self addSubview:label];
    //把小红点移到最顶层
    [self bringSubviewToFront:label];
}

- (void)hideRedPointAtIndex:(NSInteger)index {
    for (UIView*subView in self.subviews) {
        if (subView.tag == 1000+index) {
            [subView removeFromSuperview];
        }
    }
}

@end
