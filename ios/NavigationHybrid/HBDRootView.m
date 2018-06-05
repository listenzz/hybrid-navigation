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
    if (self.passThroughTouches && hitView) {
        UIView *view = self.contentView.subviews.firstObject;
        while (view) {
            if (view == hitView) {
               if (CGRectEqualToRect(view.frame, self.bounds)) {
                    return nil;
                } else {
                    break;
                }
            } else {
                view = view.subviews.firstObject;
            }
        }
    }
    return hitView;
}

@end
