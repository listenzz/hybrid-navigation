//
//  HBDNavigationBar.m
//  NavigationHybrid
//
//  Created by Listen on 2018/3/6.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDNavigationBar.h"
#import "HBDTitleView.h"

@implementation HBDNavigationBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        if ([self alphaView].alpha > 0.01) {
            for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
                CGPoint convertedPoint = [subview convertPoint:point fromView:self];
                UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
                if (hitTestView) {
                    return hitTestView;
                }
            }
            return self;
        }
    }
    return nil;
}

- (UIView *)alphaView {
    id backgroundView = self.subviews[0];
    UIView *alphaView;
    if ([self isTranslucent]) {
        if (@available(iOS 10.0, *)) {
            UIImage *backgroundImage = [self backgroundImageForBarMetrics:UIBarMetricsDefault];
            if (!backgroundImage) {
                // NSLog(@"_backgroundEffectView");
                alphaView = [backgroundView valueForKey:@"_backgroundEffectView"];
            }
        } else {
            UIView *adaptiveBackdrop = [backgroundView valueForKey:@"_adaptiveBackdrop"];
            if (adaptiveBackdrop) {
                // NSLog(@"_backdropEffectView");
                alphaView = [adaptiveBackdrop valueForKey:@"_backdropEffectView"];
            }
        }
    }
    
    if (!alphaView) {
        alphaView = backgroundView;
    }
    
    return alphaView;
}

@end
