#import "HBDReactTabBar.h"

#import <React/RCTRootView.h>

@interface HBDReactTabBar ()

@property(nonatomic, strong) RCTRootView *rootView;

@end

@implementation HBDReactTabBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }

    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self.rootView) {
        return hitView;
    }
    CGPoint convertedPoint = [self.rootView convertPoint:point fromView:self];
    if ([self.rootView pointInside:convertedPoint withEvent:event]) {
        return [self.rootView hitTest:convertedPoint withEvent:event];
    }
    return hitView;
}

- (void)addSubview:(UIView *)view {
    if ([view isKindOfClass:[RCTRootView class]]) {
        self.rootView = (RCTRootView *) view;
    }
    [super addSubview:view];
}

@end
