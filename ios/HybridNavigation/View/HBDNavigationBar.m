//
//  HBDNavigationBar.m
//  HybridNavigation
//
//  Created by Listen on 2018/3/6.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDNavigationBar.h"
#import "HBDTitleView.h"
#import "HBDUtils.h"

@interface HBDNavigationBar()

@property (nonatomic, strong, readwrite) UIImageView *shadowImageView;
@property (nonatomic, strong, readwrite) UIVisualEffectView *fakeView;

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
            NSArray *array = @[ @"UINavigationItemButtonView" ];
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
    
    NSArray *array = @[ @"UINavigationBarContentView", @"UIButtonBarStackView", @"HBDNavigationBar" ];
    if ([array containsObject:viewName]) {
        if (self.fakeView.alpha < 0.01) {
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
    self.fakeView.frame = self.fakeView.superview.bounds;
    self.shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.shadowImageView.superview.bounds), CGRectGetWidth(self.shadowImageView.superview.bounds), 0.5);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    self.fakeView.subviews.lastObject.backgroundColor =  barTintColor;
    [self makeSureFakeView];
}

- (UIView *)fakeView {
    if (!_fakeView) {
        [super setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _fakeView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _fakeView.userInteractionEnabled = NO;
        _fakeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_fakeView atIndex:0];
    }
    return _fakeView;
}

- (void)setTranslucent:(BOOL)translucent {
    // prevent default behavior
    [super setTranslucent:YES];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    
}

- (void)setShadowImage:(UIImage *)shadowImage {
    self.shadowImageView.image = shadowImage;
    if (shadowImage) {
        self.shadowImageView.backgroundColor = nil;
    } else {
        self.shadowImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:77.0/255];
    }
}

- (UIImageView *)shadowImageView {
    if (!_shadowImageView) {
        [super setShadowImage:[UIImage new]];
        _shadowImageView = [[UIImageView alloc] init];
        _shadowImageView.userInteractionEnabled = NO;
        _shadowImageView.contentScaleFactor = 1;
        [[self.subviews firstObject] insertSubview:_shadowImageView aboveSubview:self.fakeView];
    }
    return _shadowImageView;
}

- (void)makeSureFakeView {
    [UIView setAnimationsEnabled:NO];
    if (!self.fakeView.superview) {
        [[self.subviews firstObject] insertSubview:_fakeView atIndex:0];
        self.fakeView.frame = self.fakeView.superview.bounds;
    }
    
    if (!self.shadowImageView.superview) {
        [[self.subviews firstObject] insertSubview:_shadowImageView aboveSubview:self.fakeView];
        self.shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.shadowImageView.superview.bounds), CGRectGetWidth(self.shadowImageView.superview.bounds), 0.5);
    }
    [UIView setAnimationsEnabled:YES];
}

- (UILabel *)backButtonLabel {
    if (@available(iOS 11, *)) ; else return nil;
    UIView *navigationBarContentView = [self valueForKeyPath:@"visualProvider.contentView"];
    __block UILabel *backButtonLabel = nil;
    [navigationBarContentView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
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
    if (@available(iOS 11, *)) ; else return;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        hbd_exchangeImplementations(class, @selector(setAttributedText:), @selector(hbd_setAttributedText:));
    });
}

- (void)hbd_setAttributedText:(NSAttributedString *)attributedText {
    if (self.hbd_specifiedTextColor) {
        NSMutableAttributedString *mutableAttributedText = [attributedText isKindOfClass:NSMutableAttributedString.class] ? attributedText : [attributedText mutableCopy];
        [mutableAttributedText addAttributes:@{ NSForegroundColorAttributeName : self.hbd_specifiedTextColor} range:NSMakeRange(0, mutableAttributedText.length)];
        attributedText = mutableAttributedText;
    }
    [self hbd_setAttributedText:attributedText];
}


@end
