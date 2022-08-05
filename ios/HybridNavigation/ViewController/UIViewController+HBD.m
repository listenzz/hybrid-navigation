#import "UIViewController+HBD.h"

#import "HBDNavigationController.h"
#import "HBDUtils.h"
#import "GlobalStyle.h"
#import "UITabBar+Badge.h"

#import <React/RCTLog.h>

@implementation UIViewController (HBD)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [self class];
        hbd_exchangeImplementations(clazz, @selector(presentViewController:animated:completion:), @selector(hbd_presentViewController:animated:completion:));
        hbd_exchangeImplementations(clazz, @selector(dismissViewControllerAnimated:completion:), @selector(hbd_dismissViewControllerAnimated:completion:));
        hbd_exchangeImplementations(clazz, @selector(viewDidAppear:), @selector(hbd_viewDidAppear:));
        hbd_exchangeImplementations(clazz, @selector(viewDidDisappear:), @selector(hbd_viewDidDisappear:));
        hbd_exchangeImplementations(clazz, @selector(didMoveToParentViewController:), @selector(hbd_didMoveToParentViewController:));
    });
}

- (void)hbd_didMoveToParentViewController:(UIViewController *)parent {
    [self hbd_didMoveToParentViewController:parent];
    self.hbd_inViewHierarchy = parent != nil;
}

- (void)hbd_viewDidAppear:(BOOL)animated {
    [self hbd_viewDidAppear:animated];
    self.hbd_viewAppeared = YES;
}

- (void)hbd_viewDidDisappear:(BOOL)animated {
    [self hbd_viewDidDisappear:animated];
    self.hbd_viewAppeared = NO;
}

- (void)hbd_presentViewController:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^)(void))completion {
    if (![self canPresentViewController]) {
        [self didReceiveResultCode:0 resultData:nil requestCode:viewController.requestCode];
        if (completion) {
            completion();
        }
        return;
    }
    [self hbd_presentViewController:viewController animated:flag completion:completion];
}

- (BOOL)canPresentViewController {
    UIViewController *presented = self.presentedViewController;
    if (presented && !presented.isBeingDismissed) {
        RCTLogWarn(@"[Navigator] Can't present since the scene had present another scene already.");
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
            [presenting didReceiveResultCode:presented.resultCode resultData:presented.resultData requestCode:presented.requestCode];
        }

        if (completion) {
            completion();
        }
    }];
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

- (BOOL)hbd_viewAppeared {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_viewAppeared:(BOOL)viewAppeared {
    objc_setAssociatedObject(self, @selector(hbd_viewAppeared), @(viewAppeared), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_inViewHierarchy {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_inViewHierarchy:(BOOL)inViewHierarchy {
    objc_setAssociatedObject(self, @selector(hbd_inViewHierarchy), @(inViewHierarchy), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_extendedLayoutDidSet {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_extendedLayoutDidSet:(BOOL)didSet {
    objc_setAssociatedObject(self, @selector(hbd_extendedLayoutDidSet), @(didSet), OBJC_ASSOCIATION_COPY_NONATOMIC);
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

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    if ([self isKindOfClass:[UITabBarController class]]) {
        UIViewController *child = ((UITabBarController *) self).selectedViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        UIViewController *child = ((UINavigationController *) self).topViewController;
        [child didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    } else if ([self isKindOfClass:[HBDDrawerController class]]) {
        UIViewController *child = ((HBDDrawerController *) self).contentController;
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
        return (HBDDrawerController *) vc;
    }

    UIViewController *parent = self.parentViewController;
    if (parent) {
        return [parent drawerController];
    }

    return nil;
}

- (void)hbd_updateTabBarItem:(NSDictionary *)option {
    UITabBarItem *tabBarItem = self.tabBarItem;
    NSUInteger index = option[@"index"] ? [option[@"index"] integerValue] : 0;

    // title
    NSString *title = option[@"title"];
    if (title != nil) {
        tabBarItem.title = title;
    }

    // icon
    NSDictionary *icon = option[@"icon"];
    if (icon != nil) {
        NSDictionary *unselected = icon[@"unselected"];
        NSDictionary *selected = icon[@"selected"];
        if (unselected) {
            tabBarItem.selectedImage = [[HBDUtils UIImage:selected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tabBarItem.image = [[HBDUtils UIImage:unselected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            tabBarItem.image = [HBDUtils UIImage:selected];
        }
    }

    // badge
    NSDictionary *badge = option[@"badge"];
    if (badge != nil) {
        BOOL hidden = badge[@"hidden"] ? [badge[@"hidden"] boolValue] : YES;
        NSString *text = hidden ? nil : (badge[@"text"] ? badge[@"text"] : nil);
        BOOL dot = hidden ? NO : (badge[@"dot"] ? [badge[@"dot"] boolValue] : NO);

        tabBarItem.badgeValue = text;
        UITabBar *tabBar = self.tabBarController.tabBar;
        if (dot) {
            [tabBar showDotBadgeAtIndex:index];
        } else {
            [tabBar hideDotBadgeAtIndex:index];
        }
    }
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

