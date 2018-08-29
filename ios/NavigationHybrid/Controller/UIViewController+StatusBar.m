//
//  UIViewController+StatusBar.m
//  NavigationHybrid
//
//  Created by Listen on 2018/8/29.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "UIViewController+StatusBar.h"
#import "HBDUtils.h"
#import <objc/runtime.h>
#import "UIViewController+HBD.h"

void hbd_exchangeImplementations(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIViewController (StatusBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        hbd_exchangeImplementations(class, @selector(viewWillLayoutSubviews), @selector(hbd_viewWillLayoutSubviews));
        hbd_exchangeImplementations(class, @selector(viewWillAppear:), @selector(hbd_viewWillAppear:));
        hbd_exchangeImplementations(class, @selector(viewDidAppear:), @selector(hbd_viewDidAppear:));
        hbd_exchangeImplementations(class, @selector(viewWillDisappear:), @selector(hbd_viewWillDisappear:));
        hbd_exchangeImplementations(class, @selector(viewDidDisappear:), @selector(hbd_viewDidDisappear:));
        hbd_exchangeImplementations(class, @selector(viewWillTransitionToSize:withTransitionCoordinator:), @selector(hbd_viewWillTransitionToSize:withTransitionCoordinator:));
    });
}

- (BOOL)hbd_inCall {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    return statusBarHeight == 40;
}

- (BOOL)hbd_statusBarHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_statusBarHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(hbd_statusBarHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)hbd_viewWillLayoutSubviews {
    [self hbd_viewWillLayoutSubviews];
    if (self.hbd_inCall && self.view.window.rootViewController.view.frame.origin.y == 0) {
        CGRect frame = self.view.window.frame;
        self.view.window.rootViewController.view.frame = CGRectMake(0, 20, CGRectGetWidth(frame), CGRectGetHeight(frame) - 20);
    }
}

- (void)hbd_viewWillAppear:(BOOL)animated {
    [self hbd_viewWillAppear:animated];
    [self setStatusBarHidden:self.hbd_statusBarHidden];
}

-(void)hbd_viewDidAppear:(BOOL)animated {
    [self hbd_viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:)name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)hbd_viewWillDisappear:(BOOL)animated {
    [self hbd_viewWillDisappear:animated];
}

-(void)hbd_viewDidDisappear:(BOOL)animated {
    [self hbd_viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)hbd_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self hbd_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (!self.hbd_inCall && !(self.view.window.rootViewController.view.frame.origin.y == 0)) {
            self.view.window.rootViewController.view.frame = self.view.window.frame;
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([self isKindOfClass:NSClassFromString(@"UIInputWindowController")]) {
            return;
        }
        UIViewController * vc = self;
        while (vc.childViewControllerForStatusBarHidden && ![vc.childViewControllerForStatusBarHidden isKindOfClass:NSClassFromString(@"UIInputWindowController")]) {
            vc = vc.childViewControllerForStatusBarHidden;
        }
        [vc setStatusBarHidden:vc.hbd_statusBarHidden];
    }];
}

- (void)statusBarFrameWillChange:(NSNotification*)notification {
     [self setStatusBarHidden:self.hbd_statusBarHidden];
}

- (void)setStatusBarHidden:(BOOL)hidden {
    if (!self.childViewControllerForStatusBarHidden && ![self isKindOfClass:NSClassFromString(@"UIInputWindowController")]) {
        hidden = hidden && !self.hbd_inCall && ![HBDUtils isIphoneX];
        UIWindow *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
        if (!statusBar) {
            return;
        }
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        [UIView animateWithDuration:0.35 animations:^{
            statusBar.transform = hidden ? CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -statusBarHeight) : CGAffineTransformIdentity;
        }];
    }
}

@end
