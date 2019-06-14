//
//  UITabBar+DotBadge.m
//  NavigationHybrid
//
//  Created by Listen on 2018/7/5.
//  Copyright © 2018年 Listen. All rights reserved.
//
#import "UITabBar+Badge.h"
#import "HBDGarden.h"

@implementation UITabBar (DotBadge)

- (void)showDotBadgeAtIndex:(NSInteger)index {
    [self hideDotBadgeAtIndex:index];
    //label为小红点，并设置label属性
    UILabel *label = [[UILabel alloc]init];
    label.tag = 1000 + index;
    
    if (@available(iOS 10.0, *)) {
        label.backgroundColor = [UITabBarItem appearance].badgeColor ?: [UIColor colorWithRed:1 green:58.0/255.0 blue:47./255. alpha:1];
    } else {
        label.backgroundColor = [UIColor colorWithRed:1 green:58.0/255.0 blue:47./255. alpha:1];
    }

    CGFloat percentX = (index + 0.5) / self.items.count;
    CGFloat x = ceilf(percentX * self.frame.size.width + 10);
    CGFloat y = 4;
    //10为小红点的高度和宽度
    label.frame = CGRectMake(x, y, 14, 14);
    [self addSubview:label];
    //把小红点移到最顶层
    [self bringSubviewToFront:label];
    
    [self styleLabel:label];
}

- (void)hideDotBadgeAtIndex:(NSInteger)index {
    for (UIView *subView in self.subviews) {
        if (subView.tag == 1000 + index) {
            [subView removeFromSuperview];
        }
    }
}

- (void)styleLabel:(UILabel *)label {
    CGRect rect = label.bounds;
    
    CGFloat radius = 7;
    CGFloat borderWidth = 4;
    UIColor *borderColor = [HBDGarden globalStyle].tabBarBackgroundColor ? [HBDGarden globalStyle].tabBarBackgroundColor : [UIColor whiteColor];
    
    //Make round
    // Create the path for to make circle
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = rect;
    maskLayer.path  = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    label.layer.mask = maskLayer;
    
    //Give Border
    //Create path for border
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                     byRoundingCorners:UIRectCornerAllCorners
                                                           cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    
    borderLayer.frame       = rect;
    borderLayer.path        = borderPath.CGPath;
    borderLayer.strokeColor = borderColor.CGColor;
    borderLayer.fillColor   = [UIColor clearColor].CGColor;
    borderLayer.lineWidth   = borderWidth;
    
    //Add this layer to give border.
    [[label layer] addSublayer:borderLayer];
}

@end
