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

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *stack = layout[self.name];
    if (stack) {
        NSArray *children = stack[@"children"];
        UIViewController *root = [[HBDReactBridgeManager get] controllerWithLayout:children.firstObject];
        if (root) {
            return [[HBDNavigationController alloc] initWithRootViewController:root];
        }
    }
    return nil;
}

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *) vc;
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < nav.childViewControllers.count; i++) {
            UIViewController *child = nav.childViewControllers[i];
            NSDictionary *graph = [[HBDReactBridgeManager get] buildRouteGraphWithViewController:child];
            [children addObject:graph];
        }

        return @{
                @"layout": @"stack",
                @"sceneId": vc.sceneId,
                @"children": children,
                @"mode": [vc hbd_mode],
        };
    }
    return nil;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *) vc;
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:nav.topViewController];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    UINavigationController *nav = [self navigationControllerForController:target];
    if (!nav) {
        resolve(@(NO));
        return;
    }
    
    if (nav.transitionCoordinator) {
        __weak typeof(self) selfObj = self;
        [nav.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [selfObj handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
        }];
        return;
    }

    if (!nav.hbd_viewAppeared) {
        __weak typeof(self) selfObj = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [selfObj handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
        });
        return;
    }

    UIViewController *viewController = nil;

    if ([action isEqualToString:@"push"]) {
        viewController = [self createViewControllerWithExtras:extras];
        if (!viewController) {
            resolve(@(NO));
            return;
        }
        viewController.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
        viewController.didShowActionBlock = ^{
            resolve(@(YES));
        };
        [nav pushViewController:viewController animated:YES];
    } else if ([action isEqualToString:@"pop"]) {
        nav.topViewController.didHideActionBlock = ^{
            resolve(@(YES));
        };
        [nav popViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"popTo"]) {
        NSArray *children = nav.childViewControllers;
        NSUInteger count = children.count;
        NSString *moduleName = extras[@"moduleName"];
        BOOL inclusive = [extras[@"inclusive"] boolValue];
        for (NSUInteger i = count; i > 0; i--) {
            NSUInteger index = i - 1;
            HBDViewController *vc = children[index];
            if ([moduleName isEqualToString:vc.moduleName] || [moduleName isEqualToString:vc.sceneId]) {
                viewController = vc;
                if (inclusive && i > 0) {
                    viewController = children[index];
                }
                break;
            }
        }

        if (viewController) {
            nav.topViewController.didHideActionBlock = ^{
                resolve(@(YES));
            };
            [nav popToViewController:viewController animated:YES];
        } else {
            resolve(@(NO));
        }
    } else if ([action isEqualToString:@"popToRoot"]) {
        nav.topViewController.didHideActionBlock = ^{
            resolve(@(YES));
        };
        [nav popToRootViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"redirectTo"]) {
        viewController = [self createViewControllerWithExtras:extras];
        if (!viewController) {
            resolve(@(NO));
            return;
        }
        viewController.didShowActionBlock = ^{
            resolve(@(YES));
        };
        [nav redirectToViewController:viewController target:target animated:YES];
    } else if ([action isEqualToString:@"pushLayout"]) {
        NSDictionary *layout = extras[@"layout"];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        if (viewController) {
            viewController.hidesBottomBarWhenPushed = nav.hidesBottomBarWhenPushed;
            viewController.didShowActionBlock = ^{
                resolve(@(YES));
            };
            [nav pushViewController:viewController animated:YES];
        } else {
            resolve(@(NO));
        }
    }
}

- (UIViewController *)createViewControllerWithExtras:(NSDictionary *)extras {
    NSString *moduleName = extras[@"moduleName"];
    HBDViewController *viewController = nil;
    if (moduleName) {
        NSDictionary *props = extras[@"props"];
        NSDictionary *options = extras[@"options"];
        viewController = [[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }
    return viewController;
}

- (UINavigationController *)navigationControllerForController:(UIViewController *)controller {
    UINavigationController *nav = nil;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *) controller;
    } else {
        nav = controller.navigationController;
    }

    if (!nav && controller.drawerController) {
        HBDDrawerController *drawer = controller.drawerController;
        if ([drawer.contentController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBar = (UITabBarController *) drawer.contentController;
            if ([tabBar.selectedViewController isKindOfClass:[UINavigationController class]]) {
                nav = tabBar.selectedViewController;
            }
        } else if ([drawer.contentController isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *) drawer.contentController;
        } else {
            nav = drawer.contentController.navigationController;
        }
    }
    return nav;
}

@end
