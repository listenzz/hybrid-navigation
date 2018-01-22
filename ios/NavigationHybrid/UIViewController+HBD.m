//
//  UIViewController+HBD.m
//
//  Created by Listen on 2018/1/22.
//

#import "UIViewController+HBD.h"
#import <objc/runtime.h>

@implementation UIViewController (HBD)

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
        UIViewController *child = ((HBDDrawerController *)self).contentController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
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
