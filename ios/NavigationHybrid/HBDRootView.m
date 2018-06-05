//
//  HBDRootView.m
//  NavigationHybrid
//
//  Created by Listen on 2018/5/31.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDRootView.h"

@implementation HBDRootView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    UIView *view = self.contentView.subviews.firstObject.subviews.firstObject.subviews.firstObject;
    if (self.passThroughTouches && hitView == view) {
        return nil;
    }
    return hitView;
}

@end
