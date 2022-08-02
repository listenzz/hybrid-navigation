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

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *screen = layout[self.name];
    if (!screen) {
        return nil;
    }
   
    NSString *moduleName = screen[@"moduleName"];
    NSDictionary *props = screen[@"props"];
    NSDictionary *options = screen[@"options"];
    return [[HBDReactBridgeManager get] viewControllerWithModuleName:moduleName props:props options:options];
}

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDViewController class]]) {
        return nil;
    }

    HBDViewController *screen = (HBDViewController *) vc;
    return @{
        @"layout": @"screen",
        @"sceneId": screen.sceneId,
        @"moduleName": RCTNullIfNil(screen.moduleName),
        @"mode": [vc hbd_mode],
    };
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *) vc;
    }
    return nil;
}

- (void)handlePresentWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    HBDNavigationController *navVC = [[HBDNavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [navVC setRequestCode:requestCode];
    [presenting presentViewController:navVC animated:YES completion:^{
        resolve(@(YES));
    }];
}

- (void)handleDismissWithViewController:(UIViewController *) vc resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    UIViewController *presenting = vc.presentingViewController;
    if (presenting) {
        [presenting dismissViewControllerAnimated:YES completion:^{
            resolve(@(YES));
        }];
    } else {
        [vc dismissViewControllerAnimated:YES completion:^{
            resolve(@(YES));
        }];
    }
}

- (void)handleShowModalWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc setRequestCode:requestCode];
    [presenting presentViewController:vc animated:YES completion:^{
        resolve(@(YES));
    }];
}

- (void)handlePresentLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    NSDictionary *layout = extras[@"layout"];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    UIViewController *viewController = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    [viewController setRequestCode:requestCode];
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [presenting presentViewController:viewController animated:YES completion:^{
        resolve(@(YES));
    }];
}

- (void)handleShowModalLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    NSDictionary *layout = extras[@"layout"];
    UIViewController *viewController = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController setRequestCode:requestCode];
    [presenting presentViewController:viewController animated:YES completion:^{
        resolve(@(YES));
    }];
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    if (!target.hbd_viewAppeared) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
        });
        return;
    }

    if ([action isEqualToString:@"present"]) {
        [self handlePresentWithViewController:target extras:extras resolve:resolve rejecter:reject];
        return;
    }
    
    if ([action isEqualToString:@"dismiss"]) {
        [self handleDismissWithViewController:target resolve:resolve rejecter:reject];
        return;
    }
    
    if ([action isEqualToString:@"showModal"]) {
        [self handleShowModalWithViewController:target extras:extras resolve:resolve rejecter:reject];
        return;
    }
    
    if ([action isEqualToString:@"hideModal"]) {
        [self handleDismissWithViewController:target resolve:resolve rejecter:reject];
        return;
    }
    
    if ([action isEqualToString:@"presentLayout"]) {
        [self handlePresentLayoutWithViewController:target extras:extras resolve:resolve rejecter:reject];
        return;
    }
    
    if ([action isEqualToString:@"showModalLayout"]) {
        [self handleShowModalLayoutWithViewController:target extras:extras resolve:resolve rejecter:reject];
        return;
    }
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

@end
