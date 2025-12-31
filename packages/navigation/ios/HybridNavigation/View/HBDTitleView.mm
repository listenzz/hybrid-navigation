#import "HBDTitleView.h"

#import <React/RCTRootViewDelegate.h>

@interface HBDTitleView () <RCTRootViewDelegate>

@property(nonatomic, assign) CGSize fittingSize;
@property(nonatomic, strong) RCTSurfaceHostingProxyRootView *rootView;
@property(nonatomic, assign) CGRect barBounds;

@end

@implementation HBDTitleView

- (instancetype)initWithRootView:(RCTSurfaceHostingProxyRootView *)rootView layoutFittingSize:(CGSize)fittingSize navigationBarBounds:(CGRect)bounds {
    if (self = [super init]) {
        rootView.backgroundColor = [UIColor clearColor];
        _rootView = rootView;
        _fittingSize = fittingSize;
        _barBounds = bounds;
        if (CGSizeEqualToSize(fittingSize, UILayoutFittingCompressedSize)) {
            rootView.delegate = self;
            rootView.sizeFlexibility = RCTRootViewSizeFlexibilityWidthAndHeight;
        } else {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            rootView.frame = bounds;
            self.bounds = bounds;
        }
        [self addSubview:rootView];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return self.fittingSize;
}

- (void)setFrame:(CGRect)frame {
    CGFloat d = self.barBounds.size.width - frame.size.width;
    if (d <= 40 && CGSizeEqualToSize(self.fittingSize, UILayoutFittingExpandedSize)) {
        [super setFrame:CGRectInset(frame, -d / 2, 0)];
    } else {
        [super setFrame:frame];
    }
}

- (void)rootViewDidChangeIntrinsicSize:(RCTSurfaceHostingProxyRootView *)rootView {
    CGPoint center = self.center;
    self.bounds = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
    self.rootView.frame = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
    self.center = center;
}

- (UINavigationBar *)navigationBarInView:(UIView *)view {
    if (!view) {
        return nil;
    }
    if ([view isKindOfClass:[UINavigationBar class]]) {
        return (UINavigationBar *) view;
    } else {
        return [self navigationBarInView:view.superview];
    }
}

@end
