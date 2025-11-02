#import "UIViewController+HBD.h"

#import "HBDNavigationController.h"
#import "HBDReactViewController.h"
#import "HBDUtils.h"
#import "GlobalStyle.h"

#import <React/RCTLog.h>

@implementation UIViewController (HBD)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [self class];
        hbd_exchangeImplementations(clazz, @selector(presentViewController:animated:completion:), @selector(hbd_presentViewController:animated:completion:));
        hbd_exchangeImplementations(clazz, @selector(dismissViewControllerAnimated:completion:), @selector(hbd_dismissViewControllerAnimated:completion:));
    });
}

- (void)hbd_presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    if (![self canPresentViewController]) {
        return;
    }
    viewController.presentingSceneId = self.sceneId;
    [self hbd_presentViewController:viewController animated:animated completion:completion];
}

- (BOOL)canPresentViewController {
    UIViewController *presented = self.presentedViewController;
    if (presented && !presented.isBeingDismissed) {
        if ([presented isKindOfClass:[HBDReactViewController class]]) {
            HBDReactViewController *vc = (HBDReactViewController *)presented;
            RCTLogInfo(@"[Navigation] Can't present since the scene had present another scene already. %@", vc.moduleName);
        } else {
            RCTLogInfo(@"[Navigation] Can't present since the scene had present another scene already. %@", NSStringFromClass([presented class]));
        }
        return NO;
    }
    return YES;
}

- (void)hbd_dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *presented = self.presentedViewController;
    UIViewController *presenting = presented.presentingViewController;
    if (!presented) {
        presenting = self.presentingViewController;
        presented = presenting.presentedViewController;
    }

    [self hbd_dismissViewControllerAnimated:animated completion:^{
        if (![presented isKindOfClass:[UIAlertController class]]) {
            BOOL consumed = presented.presentingSceneId && [UIViewController dispatchResult:presenting presented:presented sceneId:presented.presentingSceneId];
            if (!consumed) {
                [presenting didReceiveResultCode:presented.resultCode resultData:presented.resultData requestCode:presented.requestCode];
            }
        }

        if (completion) {
            completion();
        }
    }];
}

+ (BOOL)dispatchResult:(UIViewController *)presenting presented:(UIViewController *)presented sceneId:(NSString *)sceneId {
    if ([sceneId isEqualToString:presenting.sceneId]) {
        [presenting didReceiveResultCode:presented.resultCode resultData:presented.resultData requestCode:presented.requestCode];
        return YES;
    }
    
    NSArray<UIViewController *> *children = presenting.childViewControllers;
    for (UIViewController *vc in children) {
        BOOL consumed = [self dispatchResult:vc presented:presented sceneId:sceneId];
        if (consumed) {
            return YES;
        }
    }
    
    return NO;
}


- (NSString *)sceneId {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        obj = [[NSUUID UUID] UUIDString];
        objc_setAssociatedObject(self, @selector(sceneId), obj, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return obj;
}

- (UIBarStyle)hbd_barStyle {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setHbd_barStyle:(UIBarStyle)hbd_barStyle {
    objc_setAssociatedObject(self, @selector(hbd_barStyle), @(hbd_barStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)hbd_barTintColor {
    if (self.hbd_barHidden) {
        return UIColor.clearColor;
    }

    id obj = objc_getAssociatedObject(self, _cmd);
    UIColor *color;
    if (obj) {
        color = obj;
    }

    UIColor *colorWithBarStyle = [[GlobalStyle globalStyle] barTintColorWithBarStyle:self.hbd_barStyle];
    if (color == nil && colorWithBarStyle != nil) {
        color = colorWithBarStyle;
    }

    if (color == nil && [UINavigationBar appearance].barTintColor != nil) {
        color = [UINavigationBar appearance].barTintColor;
    }

    if (color == nil) {
        color = [UINavigationBar appearance].barStyle == UIBarStyleDefault ? [UIColor whiteColor] : [UIColor blackColor];
    }

    return color;
}

- (void)setHbd_barTintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(hbd_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hbd_tintColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj;
    }

    UIColor *colorWithBarStyle = [[GlobalStyle globalStyle] tintColorWithBarStyle:self.hbd_barStyle];
    if (colorWithBarStyle) {
        return colorWithBarStyle;
    }

    return [UINavigationBar appearance].tintColor;
}

- (void)setHbd_tintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(hbd_tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)hbd_titleTextAttributes {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj;
    }

    UIBarStyle barStyle = self.hbd_barStyle;
    UIColor *colorWithBarStyle = [[GlobalStyle globalStyle] titleTextColorWithBarStyle:barStyle];
    NSDictionary *colorAttributes = @{NSForegroundColorAttributeName: colorWithBarStyle};
    NSDictionary *attributes = [UINavigationBar appearance].titleTextAttributes;
    if (attributes) {
        NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
        [mutableAttributes addEntriesFromDictionary:colorAttributes];
        return mutableAttributes;
    } else {
        return colorAttributes;
    }
}

- (void)setHbd_titleTextAttributes:(NSDictionary *)attributes {
    objc_setAssociatedObject(self, @selector(hbd_titleTextAttributes), attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)hbd_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.hbd_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setHbd_barAlpha:(float)alpha {
    objc_setAssociatedObject(self, @selector(hbd_barAlpha), @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_barHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_barHidden:(BOOL)hidden {
    if (hidden) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.titleView = [UIView new];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }
    objc_setAssociatedObject(self, @selector(hbd_barHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)hbd_barShadowAlpha {
    return self.hbd_barShadowHidden ? 0 : self.hbd_barAlpha;
}

- (BOOL)hbd_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return self.hbd_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setHbd_barShadowHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(hbd_barShadowHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_statusBarHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_statusBarHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(hbd_statusBarHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(hbd_backInteractive), @(interactive), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_swipeBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_swipeBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(hbd_swipeBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)hbd_setNeedsUpdateNavigationBar {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *) self.navigationController;
        if (self == nav.topViewController) {
            [nav updateNavigationBarForViewController:self];
        }
    }
}

- (void)setResultCode:(NSInteger)resultCode {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        objc_setAssociatedObject(presenting.presentedViewController, @selector(resultCode), @(resultCode), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    objc_setAssociatedObject(self, @selector(resultCode), @(resultCode), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)resultCode {
    NSNumber *code = objc_getAssociatedObject(self, _cmd);
    return [code integerValue];
}

- (void)setResultData:(NSDictionary *)data {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        objc_setAssociatedObject(presenting.presentedViewController, @selector(resultData), data, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    objc_setAssociatedObject(self, @selector(resultData), data, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)resultData {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRequestCode:(NSInteger)requestCode {
    objc_setAssociatedObject(self, @selector(requestCode), @(requestCode), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)requestCode {
    NSNumber *code = objc_getAssociatedObject(self, _cmd);
    return [code integerValue];
}

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data {
    self.resultCode = resultCode;
    self.resultData = data;
}

- (NSString *)presentingSceneId {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPresentingSceneId:(NSString *)presentingSceneId {
    objc_setAssociatedObject(self, @selector(presentingSceneId), presentingSceneId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    if ([self isKindOfClass:[UITabBarController class]]) {
        UIViewController *child = ((UITabBarController *) self).selectedViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
        return;
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        UIViewController *child = ((UINavigationController *) self).topViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
        return;
    }
    
    if ([self isKindOfClass:[HBDDrawerController class]]) {
        UIViewController *child = ((HBDDrawerController *) self).contentController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
        return;
    }
    
    NSArray *children = self.childViewControllers;
    for (UIViewController *vc in children) {
        [vc didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    }
}

- (HBDDrawerController *)drawerController {
    UIViewController *vc = self;

    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        return (HBDDrawerController *) vc;
    }

    UIViewController *parent = self.parentViewController;
    if (parent) {
        return [parent drawerController];
    }

    return nil;
}

- (NSString *)hbd_mode {
    if (self.modalPresentationStyle == UIModalPresentationOverFullScreen) {
        return @"modal";
    } else if (self.presentingViewController != nil) {
        return @"present";
    } else {
        return @"normal";
    }
}

@end

