#import "HBDRootView.h"

@interface HBDRootView ()

@property (nonatomic, strong, readonly) RCTRootView *rootView;

@end

@implementation HBDRootView

- (instancetype)initWithRootView:(RCTRootView *)rootView {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _rootView = rootView;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.rootView.passThroughTouches) {
        if (hitView == self) {
            return nil;
        }
        
        if (hitView && CGRectEqualToRect(hitView.frame, self.rootView.bounds)) {
            return nil;
        }
    }
    return hitView;
}

@end
