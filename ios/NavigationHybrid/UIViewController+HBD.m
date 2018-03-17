//
//  UIViewController+HBD.m
//  NavigationHybrid
//
//  Created by Listen on 2018/1/22.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "UIViewController+HBD.h"
#import <objc/runtime.h>

@implementation UIViewController (HBD)

- (UIColor *)topBarColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].barTintColor;
}

- (void)setTopBarColor:(UIColor *)topBarColor {
    objc_setAssociatedObject(self, @selector(topBarColor), topBarColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)topBarAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setTopBarAlpha:(float)topBarAlpha {
    objc_setAssociatedObject(self, @selector(topBarAlpha), @(topBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)topBarHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setTopBarHidden:(BOOL)topBarHidden {
    objc_setAssociatedObject(self, @selector(topBarHidden), @(topBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)topBarShadowAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setTopBarShadowAlpha:(float)topBarShadowAlpha {
    objc_setAssociatedObject(self, @selector(topBarShadowAlpha), @(topBarShadowAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)topBarShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setTopBarShadowHidden:(BOOL)topBarShadowHidden {
    objc_setAssociatedObject(self, @selector(topBarShadowHidden), @(topBarShadowHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setBackInteractive:(BOOL)backInteractive {
    objc_setAssociatedObject(self, @selector(backInteractive), @(backInteractive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data {
    [self setResultCode:@(resultCode)];
    [self setResultData:data];
}

- (void)setResultCode:(NSNumber *)resultCode {
    objc_setAssociatedObject(self, @selector(resultCode), resultCode, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)resultCode {
    NSNumber *code = objc_getAssociatedObject(self, _cmd);
    return [code integerValue];
}

- (void)setResultData:(NSDictionary *)data {
    objc_setAssociatedObject(self, @selector(resultData), data, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)resultData {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRequestCode:(NSInteger)requestCode {
    objc_setAssociatedObject(self, @selector(requestCode), @(requestCode), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)requestCode {
    UIViewController *parent =  [self parentViewController];
    if (parent) {
        return [parent requestCode];
    }
    NSNumber *code = objc_getAssociatedObject(self, _cmd);
    return [code integerValue];
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    if ([self isKindOfClass:[UITabBarController class]]) {
        UIViewController *child = ((UITabBarController *)self).selectedViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        UIViewController *child = ((UINavigationController *)self).topViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    } else if ([self isKindOfClass:[HBDDrawerController class]]) {
        UIViewController *child = ((HBDDrawerController *)self).contentViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    } else {
        NSArray *children = self.childViewControllers;
        if (children) {
            for (UIViewController *vc in children) {
                [vc didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
            }
        }
    }
}

- (HBDDrawerController *)drawerController {
    UIViewController *vc = self;
    
    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        return (HBDDrawerController *)vc;
    }
    
    UIViewController *parent = self.parentViewController;
    if (parent) {
        return [parent drawerController];
    }
    
    return nil;
}

@end

