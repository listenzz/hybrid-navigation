#import "HBDStackNavigator.h"

#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"
#import "UINavigationController+HBD.h"
#import "HBDAnimationObserver.h"

#import <React/RCTLog.h>

@implementation HBDStackNavigator

- (NSString *)name {
    return @"stack";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"push", @"pushLayout", @"pop", @"popTo", @"popToRoot", @"redirectTo"];
}

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *model = layout[self.name];
    if (!model) {
        return nil;
    }
    
    NSArray *children = model[@"children"];
    UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:children.firstObject];
    return [[HBDNavigationController alloc] initWithRootViewController:vc];
}

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDNavigationController class]]) {
        return nil;
    }
    
    HBDNavigationController *nav = (HBDNavigationController *) vc;
    
    NSMutableArray *children = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < nav.childViewControllers.count; i++) {
        UIViewController *child = nav.childViewControllers[i];
        NSDictionary *graph = [[HBDReactBridgeManager get] routeGraphWithViewController:child];
        [children addObject:graph];
    }

    return @{
        @"layout": @"stack",
        @"sceneId": nav.sceneId,
        @"children": children,
        @"mode": [nav hbd_mode],
    };
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[UINavigationController class]]) {
        return nil;
    }
    UINavigationController *nav = (UINavigationController *)vc;
    return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:nav.topViewController];
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UINavigationController *nav = [self navigationControllerForViewController:vc];
    if (!nav) {
        RCTLogInfo(@"[Navigation] 找不到对应的 UINavigationController from:%@", extras[@"from"]);
        callback(@[NSNull.null, @NO]);
        return;
    }

    if (nav.transitionCoordinator) {
        RCTLogInfo(@"[Navigation] 等待上个 action 执行完成 from:%@ %@ to:%@", extras[@"from"], action, extras[@"to"]);
        [nav.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            // empty
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            // 确保最后执行
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleNavigationWithViewController:vc action:action extras:extras callback:callback];
            });
        }];
        return;
    }

    if ([action isEqualToString:@"push"]) {
        [self handlePushWithNavigationController:nav extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"pop"]) {
        [self handlePopWithNavigationController:nav viewController:vc callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"popTo"]) {
        [self handlePopToWithNavigationController:nav extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"popToRoot"]) {
        [self handlePopToRootWithNavigationController:nav extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"redirectTo"]) {
        [self handleRedirectToWithNavigationController:nav target:vc extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"pushLayout"]) {
        [self handlePushLayoutWithNavigationController:nav extras:extras callback:callback];
        return;
    }
}

- (void)handlePushWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    if (!vc) {
        RCTLogInfo(@"[Navigation] 无法创建对应的页面 %@", extras[@"moduleName"]);
        callback(@[NSNull.null, @NO]);
        return;
    }

    vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
    
    BOOL animated = YES;
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hdbvc = (HBDViewController *)vc;
        animated = hdbvc.animatedTransition;
    }
    
    if (animated) {
        [[HBDAnimationObserver sharedObserver] beginAnimation];
        [nav pushViewController:vc animated:YES];
        [self animateAlongsideTransition:nav callback:callback];
    } else {
        [nav pushViewController:vc animated:NO];
        callback(@[NSNull.null, @YES]);
    }
}

- (void)handlePopWithNavigationController:(UINavigationController *)nav viewController:(UIViewController *)vc callback:(RCTResponseSenderBlock)callback {
    BOOL animated = YES;
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hdbvc = (HBDViewController *)vc;
        animated = hdbvc.animatedTransition;
    }
    
    if (animated) {
        [nav popViewControllerAnimated:YES];
        [self animateAlongsideTransition:nav callback:callback];
    } else {
        [nav popViewControllerAnimated:NO];
        callback(@[NSNull.null, @YES]);
    }
}

- (void)handlePopToWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self findViewControllerWithNavigationController:nav extras:extras];
    if (!vc) {
        RCTLogInfo(@"[Navigation] 找不到要 popTo 的页面 %@", extras[@"moduleName"]);
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    UIViewController *from_vc = [self findFromViewControllerWithNavigationController:nav extras:extras];
    
    BOOL animated = YES;
    if ([from_vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdvc = (HBDViewController *)from_vc;
        animated = hbdvc.animatedTransition;
    }
    
    if (animated) {
        [nav popToViewController:vc animated:YES];
        [self animateAlongsideTransition:nav callback:callback];
    }else {
        [nav popToViewController:vc animated:NO];
        callback(@[NSNull.null, @YES]);
    }
    
}

- (UIViewController *)findFromViewControllerWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras {
    NSArray *children = nav.childViewControllers;
    NSString *moduleName = extras[@"from"];
    BOOL inclusive = [extras[@"inclusive"] boolValue];
    
    for (NSUInteger i = children.count; i > 0; i--) {
        NSUInteger index = i - 1;
        HBDViewController *vc = children[index];
        if ([moduleName isEqualToString:vc.moduleName] || [moduleName isEqualToString:vc.sceneId]) {
            if (inclusive && index > 0) {
                return children[index - 1];
            }
            return vc;
        }
    }
    
    return nil;
}

- (UIViewController *)findViewControllerWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras {
    NSArray *children = nav.childViewControllers;
    NSString *moduleName = extras[@"moduleName"];
    BOOL inclusive = [extras[@"inclusive"] boolValue];
    
    for (NSUInteger i = children.count; i > 0; i--) {
        NSUInteger index = i - 1;
        HBDViewController *vc = children[index];
        if ([moduleName isEqualToString:vc.moduleName] || [moduleName isEqualToString:vc.sceneId]) {
            if (inclusive && index > 0) {
                return children[index - 1];
            }
            return vc;
        }
    }
    
    return nil;
}

- (void)handlePopToRootWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    
    UIViewController *from_vc = [self findFromViewControllerWithNavigationController:nav extras:extras];
    
    BOOL animated = YES;
    
    if ([from_vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdvc = (HBDViewController *)from_vc;
        animated = hbdvc.animatedTransition;
    }
    
    if (animated) {
        [nav popToRootViewControllerAnimated:YES];
        [self animateAlongsideTransition:nav callback:callback];
    }else {
        [nav popToRootViewControllerAnimated:NO];
        callback(@[NSNull.null, @YES]);
    }
}

- (void)handleRedirectToWithNavigationController:(UINavigationController *)nav target:(UIViewController *)target extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    if (!vc) {
        RCTLogInfo(@"[Navigation] 无法创建对应的页面 %@", extras[@"moduleName"]);
        callback(@[NSNull.null, @NO]);
        return;
    }
    BOOL animated = YES;
    
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdvc = (HBDViewController *)vc;
        animated = hbdvc.animatedTransition;
    }
    
    if (animated) {
        [[HBDAnimationObserver sharedObserver] beginAnimation];
        [nav redirectToViewController:vc target:target animated:YES];
        [self animateAlongsideTransition:nav callback:callback];
    }else {
        [nav redirectToViewController:vc target:target animated:NO];
        callback(@[NSNull.null, @YES]);
    }
    
}

- (void)handlePushLayoutWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSDictionary *layout = extras[@"layout"];
    UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    if (!vc) {
        RCTLogInfo(@"[Navigation] 无法创建对应的 vc");
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
    [[HBDAnimationObserver sharedObserver] beginAnimation];
    [nav pushViewController:vc animated:YES];
    [self animateAlongsideTransition:nav callback:callback];
}

- (void)animateAlongsideTransition:(UINavigationController *)nav callback:(RCTResponseSenderBlock)callback {
    if (!nav.transitionCoordinator) {
        callback(@[NSNull.null, @YES]);
        return;
    }
    
    [nav.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // empty
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        callback(@[NSNull.null, @YES]);
    }];
}

- (UIViewController *)viewControllerWithExtras:(NSDictionary *)extras {
    NSString *moduleName = extras[@"moduleName"];
    NSDictionary *props = extras[@"props"];
    NSDictionary *options = extras[@"options"];
    return [[HBDReactBridgeManager get] viewControllerWithModuleName:moduleName props:props options:options];
}

- (UINavigationController *)navigationControllerForViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)vc;
    }
    
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        return  nav;
    }
    
    HBDDrawerController *drawer = vc.drawerController;
    if (!drawer) {
        return nil;
    }
    
    if ([drawer.contentController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabs = (UITabBarController *)drawer.contentController;
        if ([tabs.selectedViewController isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)tabs.selectedViewController;
        }
        return nil;
    }
    
    if ([drawer.contentController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)drawer.contentController;
    }
    
    return drawer.contentController.navigationController;
}

- (void)invalidate {
     // 
}

@end
