#import "HBDNavigationBar.h"

#import "HBDUtils.h"

#define hairlineWidth (1.f/[UIScreen mainScreen].scale)

@interface HBDNavigationBar ()

@property(nonatomic, strong, readwrite) UIImageView *fakeShadowView;
@property(nonatomic, strong, readwrite) UIView *fakeBackgroundView;

@end

@implementation HBDNavigationBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }

    UIView *view = [super hitTest:point withEvent:event];
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];

    if (view && [viewName isEqualToString:@"HBDNavigationBar"]) {
        for (UIView *subview in self.subviews) {
            NSString *viewName = [[[subview classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            NSArray *array = @[@"UINavigationItemButtonView"];
            if ([array containsObject:viewName]) {
                CGPoint convertedPoint = [self convertPoint:point toView:subview];
                CGRect bounds = subview.bounds;
                if (bounds.size.width < 80) {
                    bounds = CGRectInset(bounds, bounds.size.width - 80, 0);
                }
                if (CGRectContainsPoint(bounds, convertedPoint)) {
                    return view;
                }
            }
        }
    }

    NSArray *array = @[@"UINavigationBarContentView", @"UIButtonBarStackView", @"HBDNavigationBar"];
    if ([array containsObject:viewName]) {
        if (self.fakeBackgroundView.alpha < 0.01) {
            return nil;
        }
    }

    if (CGRectEqualToRect(view.bounds, CGRectZero)) {
        return nil;
    }

    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fakeBackgroundView.frame = self.fakeBackgroundView.superview.bounds;
    self.fakeShadowView.frame = CGRectMake(0, CGRectGetHeight(self.fakeShadowView.superview.bounds) - hairlineWidth, CGRectGetWidth(self.fakeShadowView.superview.bounds), hairlineWidth);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    self.fakeBackgroundView.backgroundColor = barTintColor;
    [self makesureFakeView];
}

- (UIView *)fakeBackgroundView {
    if (!_fakeBackgroundView) {
        [super setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _fakeBackgroundView = [[UIView alloc] init];
        _fakeBackgroundView.userInteractionEnabled = NO;
        _fakeBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _fakeBackgroundView;
}

- (void)setTranslucent:(BOOL)translucent {
    // prevent default behavior
    [super setTranslucent:YES];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {

}

- (void)setShadowImage:(UIImage *)shadowImage {
    self.fakeShadowView.image = shadowImage;
    if (shadowImage) {
        self.fakeShadowView.backgroundColor = nil;
    } else {
        self.fakeShadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:77.0 / 255];
    }

}

- (UIImageView *)fakeShadowView {
    if (!_fakeShadowView) {
        [super setShadowImage:[UIImage new]];
        _fakeShadowView = [[UIImageView alloc] init];
        _fakeShadowView.userInteractionEnabled = NO;
        _fakeShadowView.contentScaleFactor = 1;
        _fakeShadowView.layer.allowsEdgeAntialiasing = YES;
    }
    return _fakeShadowView;
}

- (void)makesureFakeView {
    [UIView setAnimationsEnabled:NO];
    if (!self.fakeBackgroundView.superview) {
        [[self.subviews firstObject] insertSubview:self.fakeBackgroundView atIndex:0];
        self.fakeBackgroundView.frame = self.fakeBackgroundView.superview.bounds;
    }

    if (!self.fakeShadowView.superview) {
        [[self.subviews firstObject] insertSubview:self.fakeShadowView aboveSubview:self.fakeBackgroundView];
        self.fakeShadowView.frame = CGRectMake(0, CGRectGetHeight(self.fakeShadowView.superview.bounds) - hairlineWidth, CGRectGetWidth(self.fakeShadowView.superview.bounds), hairlineWidth);
    }
    [UIView setAnimationsEnabled:YES];
}

- (UILabel *)backButtonLabel {
    UIView *navigationBarContentView = [self valueForKeyPath:@"visualProvider.contentView"];
    __block UILabel *backButtonLabel = nil;
    [navigationBarContentView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView *_Nonnull subview, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([subview isKindOfClass:NSClassFromString(@"_UIButtonBarButton")]) {
            UIButton *titleButton = [subview valueForKeyPath:@"visualProvider.titleButton"];
            backButtonLabel = titleButton.titleLabel;
            *stop = YES;
        }
    }];
    return backButtonLabel;
}

@end

@implementation UILabel (NavigationBarTransition)

- (UIColor *)hbd_specifiedTextColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_specifiedTextColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(hbd_specifiedTextColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class klass = [self class];
        hbd_exchangeImplementations(klass, @selector(setAttributedText:), @selector(hbd_setAttributedText:));
    });
}

- (void)hbd_setAttributedText:(NSAttributedString *)attributedText {
    if (self.hbd_specifiedTextColor) {
        NSMutableAttributedString *mutableAttributedText = [attributedText isKindOfClass:NSMutableAttributedString.class] ? attributedText : [attributedText mutableCopy];
        [mutableAttributedText addAttributes:@{NSForegroundColorAttributeName: self.hbd_specifiedTextColor} range:NSMakeRange(0, mutableAttributedText.length)];
        attributedText = mutableAttributedText;
    }
    [self hbd_setAttributedText:attributedText];
}


@end
