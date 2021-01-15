//
//  HBDTitleView.m
//  NavigationHybrid
//
//  Created by Listen on 2018/3/6.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDTitleView.h"
#import <React/RCTRootViewDelegate.h>

@interface HBDTitleView() <RCTRootViewDelegate>

@property (nonatomic, assign) CGSize fittingSize;
@property (nonatomic, strong) RCTRootView *rootView;
@property (nonatomic, assign) CGRect barBounds;

@end

@implementation HBDTitleView

- (instancetype)initWithRootView:(RCTRootView *)rootView layoutFittingSize:(CGSize)fittingSize navigationBarBounds:(CGRect)bounds {
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

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    CGPoint center = self.center;
    self.bounds = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
    self.rootView.frame = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
    self.center = center;
    
    // 修正版本在 10.0 的情况
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue < 11.0) {
        UINavigationBar *bar = [self navigationBarInView:self];
        if (bar) {
            for (UIView *subview in bar.subviews) {
                NSString *viewName = [[[subview classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
                if ([viewName isEqualToString:@"UINavigationItemButtonView"]) {
                    CGFloat dx = subview.frame.origin.x + subview.frame.size.width + self.bounds.size.width /2 + 6 - center.x;
                    if (dx > 0) {
                        self.center = CGPointMake(center.x + dx, center.y);
                    }
                    break;
                }
            }
        }
    }
}

- (UINavigationBar *)navigationBarInView:(UIView *)view {
    if (!view) {
        return nil;
    }
    if ([view isKindOfClass:[UINavigationBar class]]) {
        return (UINavigationBar *)view;
    } else {
        return [self navigationBarInView:view.superview];
    }
}

@end
