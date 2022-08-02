#import "HBDScreenNavigator.h"

#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"

#import <React/RCTLog.h>

@implementation HBDScreenNavigator

- (NSString *)name {
    return @"screen";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"present", @"presentLayout", @"dismiss", @"showModal", @"showModalLayout", @"hideModal"];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *screen = layout[self.name];
    if (screen) {
        NSString *moduleName = screen[@"moduleName"];
        NSDictionary *props = screen[@"props"];
        NSDictionary *options = screen[@"options"];
        return [[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }
    return nil;
}

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *screen = (HBDViewController *) vc;
        return @{
                @"layout": @"screen",
                @"sceneId": screen.sceneId,
                @"moduleName": RCTNullIfNil(screen.moduleName),
                @"mode": [vc hbd_mode],
        };
    }
    return nil;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *) vc;
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {

    if (!target.hbd_viewAppeared) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
        });
        return;
    }

    UIViewController *viewController = nil;

    if ([action isEqualToString:@"present"]) {
        viewController = [self createViewControllerWithExtras:extras];
        NSInteger requestCode = [extras[@"requestCode"] integerValue];
        HBDNavigationController *navVC = [[HBDNavigationController alloc] initWithRootViewController:viewController];
        navVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [navVC setRequestCode:requestCode];
        [target presentViewController:navVC animated:YES completion:^{
            resolve(@(YES));
        }];
    } else if ([action isEqualToString:@"dismiss"]) {
        UIViewController *presenting = target.presentingViewController;
        if (presenting) {
            [presenting dismissViewControllerAnimated:YES completion:^{
                resolve(@(YES));
            }];
        } else {
            [target dismissViewControllerAnimated:YES completion:^{
                resolve(@(YES));
            }];
        }
    } else if ([action isEqualToString:@"showModal"]) {
        viewController = [self createViewControllerWithExtras:extras];
        NSInteger requestCode = [extras[@"requestCode"] integerValue];
        viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [viewController setRequestCode:requestCode];
        [target presentViewController:viewController animated:YES completion:^{
            resolve(@(YES));
        }];
    } else if ([action isEqualToString:@"hideModal"]) {
        UIViewController *presenting = target.presentingViewController;
        if (presenting) {
            [presenting dismissViewControllerAnimated:YES completion:^{
                resolve(@(YES));
            }];
        } else {
            [target dismissViewControllerAnimated:YES completion:^{
                resolve(@(YES));
            }];
        }
    } else if ([action isEqualToString:@"presentLayout"]) {
        NSDictionary *layout = extras[@"layout"];
        NSInteger requestCode = [extras[@"requestCode"] integerValue];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        [viewController setRequestCode:requestCode];
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [target presentViewController:viewController animated:YES completion:^{
            resolve(@(YES));
        }];
    } else if ([action isEqualToString:@"showModalLayout"]) {
        NSInteger requestCode = [extras[@"requestCode"] integerValue];
        NSDictionary *layout = extras[@"layout"];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [viewController setRequestCode:requestCode];
        [target presentViewController:viewController animated:YES completion:^{
            resolve(@(YES));
        }];
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

@end
