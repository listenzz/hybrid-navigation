#import "HBDRootView.h"

@interface HBDRootView ()

@property (nonatomic, strong, readonly) RCTRootView *rootView;

@end

@implementation HBDRootView

- (instancetype)initWithRootView:(RCTRootView *)rootView {
    if (self = [super init]) {
        _rootView = rootView;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.rootView.passThroughTouches && hitView == self) {
        return nil;
    }
    return hitView;
}

@end
