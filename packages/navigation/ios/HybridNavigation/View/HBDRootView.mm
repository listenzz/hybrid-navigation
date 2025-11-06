#import "HBDRootView.h"

@interface HBDRootView ()

@property (nonatomic, strong, readonly) RCTSurfaceHostingProxyRootView *rootView;

@end

@implementation HBDRootView

- (instancetype)initWithRootView:(RCTSurfaceHostingProxyRootView *)rootView {
    if (self = [super initWithFrame:CGRectZero]) {
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
