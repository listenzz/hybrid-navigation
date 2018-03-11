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

@end

@implementation HBDTitleView

- (instancetype)initWithRootView:(RCTRootView *)rootView layoutFittingSize:(CGSize)fittingSize navigationBarBounds:(CGRect)bounds {
    if (self = [super init]) {
        rootView.backgroundColor = [UIColor clearColor];
        _rootView = rootView;
        _fittingSize = fittingSize;
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

- (void)setFrame:(CGRect)frame {
    
    if (@available(iOS 11.0, *)) {
        // nothing to do
    } else {
        if (CGSizeEqualToSize(self.fittingSize, UILayoutFittingCompressedSize)) {
            UINavigationBar *bar = [self navigationBarInView:self.superview];
            if (bar) {
               frame = CGRectOffset(frame, (bar.bounds.size.width - frame.size.width + 0.5)/2 - frame.origin.x, (bar.bounds.size.height - frame.size.height + 0.5)/2 - frame.origin.y);
            }
        }
    }
    
    [super setFrame:frame];
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

- (CGSize)intrinsicContentSize {
    return self.fittingSize;
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    self.frame = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
    self.rootView.frame = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
}

@end
