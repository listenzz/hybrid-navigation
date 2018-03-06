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
            rootView.sizeFlexibility = RCTRootViewSizeFlexibilityWidthAndHeight;
            rootView.delegate = self;
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
    if (self.superview.bounds.size.width == [UIScreen mainScreen].bounds.size.width - 16) {
        frame = CGRectInset(self.superview.bounds, -8, 0);
    }
    [super setFrame:frame];
}

- (CGSize)intrinsicContentSize {
    return self.fittingSize;
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    self.rootView.frame = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
    self.frame = CGRectMake(0, 0, rootView.intrinsicContentSize.width, rootView.intrinsicContentSize.height);
}

@end
