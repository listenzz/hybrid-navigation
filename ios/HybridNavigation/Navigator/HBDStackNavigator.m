#import "HBDStackNavigator.h"

#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"
#import "UINavigationController+HBD.h"

@implementation HBDStackNavigator

- (NSString *)name {
    return @"stack";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"push", @"pushLayout", @"pop", @"popTo", @"popToRoot", @"redirectTo"];
}

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *stack = layout[self.name];
    if (!stack) {
        return nil;
    }
    
    NSArray *children = stack[@"children"];
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
        @"sceneId": vc.sceneId,
        @"children": children,
        @"mode": [vc hbd_mode],
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
    if (!vc.hbd_inViewHierarchy) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    UINavigationController *nav = [self navigationControllerForViewController:vc];
    if (!nav) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    if (nav.transitionCoordinator) {
        [nav.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            // empty
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            [self handleNavigationWithViewController:vc action:action extras:extras callback:callback];
        }];
        return;
    }

    if (!nav.hbd_viewAppeared) {
        [self performSelector:@selector(handleNavigation:) withObject:@{
            @"viewController": vc,
            @"action": action,
            @"extras": extras,
            @"callback": callback,
        } afterDelay:0.05];
        return;
    }

    if ([action isEqualToString:@"push"]) {
        [self handlePushWithNavigationController:nav extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"pop"]) {
        [self handlePopWithNavigationController:nav callback:callback];
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

- (void)handlePushWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras  callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    if (!vc) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
    [nav pushViewController:vc animated:YES];
    [self animateAlongsideTransition:nav callback:callback];
}

- (void)handlePopWithNavigationController:(UINavigationController *)nav callback:(RCTResponseSenderBlock)callback {
    [nav popViewControllerAnimated:YES];
    [self animateAlongsideTransition:nav callback:callback];
}

- (void)handlePopToWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras  callback:(RCTResponseSenderBlock)callback {
    NSArray *children = nav.childViewControllers;
    NSUInteger count = children.count;
    NSString *moduleName = extras[@"moduleName"];
    BOOL inclusive = [extras[@"inclusive"] boolValue];
    
    for (NSUInteger i = count; i > 0; i--) {
        NSUInteger index = i - 1;
        HBDViewController *vc = children[index];
        if ([moduleName isEqualToString:vc.moduleName] || [moduleName isEqualToString:vc.sceneId]) {
            UIViewController *viewController = vc;
            if (inclusive && i > 0) {
                viewController = children[index - 1];
            }
            [nav popToViewController:viewController animated:YES];
            [self animateAlongsideTransition:nav callback:callback];
            return;
        }
    }
    
    callback(@[NSNull.null, @NO]);
}

- (void)handlePopToRootWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras  callback:(RCTResponseSenderBlock)callback {
    [nav popToRootViewControllerAnimated:YES];
    [self animateAlongsideTransition:nav callback:callback];
}

- (void)handleRedirectToWithNavigationController:(UINavigationController *)nav target:(UIViewController *)target extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    if (!vc) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    [nav redirectToViewController:vc target:target animated:YES];
    [self animateAlongsideTransition:nav callback:callback];
}

- (void)handlePushLayoutWithNavigationController:(UINavigationController *)nav extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSDictionary *layout = extras[@"layout"];
    UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    if (!vc) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    vc.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
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
    if (!moduleName) {
        return nil;
    }
    
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
        UITabBarController *tabBar = (UITabBarController *) drawer.contentController;
        if ([tabBar.selectedViewController isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)tabBar.selectedViewController;
        }
        return nil;
    }
    
    if ([drawer.contentController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *) drawer.contentController;
    }
    
    return nil;
}

-(void)handleNavigation:(NSDictionary *)params {
    [self handleNavigationWithViewController:params[@"viewController"] action:params[@"action"] extras:params[@"extras"] callback:params[@"callback"]];
}

- (void)invalidate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
