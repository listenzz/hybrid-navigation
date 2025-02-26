#import "HBDScreenNavigator.h"

#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"
#import "HBDAnimationObserver.h"

#import <React/RCTLog.h>

@implementation HBDScreenNavigator

- (NSString *)name {
    return @"screen";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"present", @"presentLayout", @"dismiss", @"showModal", @"showModalLayout", @"hideModal"];
}

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *model = layout[self.name];
    if (!model) {
        return nil;
    }
   
    NSString *moduleName = model[@"moduleName"];
    NSDictionary *props = model[@"props"];
    NSDictionary *options = model[@"options"];
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
        @"mode": [screen hbd_mode],
    };
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *) vc;
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    if ([action isEqualToString:@"present"]) {
        [self handlePresentWithViewController:vc extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"dismiss"]) {
        [self handleDismissWithViewController:vc callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"showModal"]) {
        [self handleShowModalWithViewController:vc extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"hideModal"]) {
        [self handleDismissWithViewController:vc callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"presentLayout"]) {
        [self handlePresentLayoutWithViewController:vc extras:extras callback:callback];
        return;
    }
    
    if ([action isEqualToString:@"showModalLayout"]) {
        [self handleShowModalLayoutWithViewController:vc extras:extras callback:callback];
        return;
    }
}

- (void)handlePresentWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    HBDNavigationController *nav = [[HBDNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    [nav setRequestCode:requestCode];
    [[HBDAnimationObserver sharedObserver] beginAnimation];
    [presenting presentViewController:nav animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleDismissWithViewController:(UIViewController *) vc callback:(RCTResponseSenderBlock)callback {
    [vc dismissViewControllerAnimated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleShowModalWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc setRequestCode:requestCode];
    [[HBDAnimationObserver sharedObserver] beginAnimation];
    [presenting presentViewController:vc animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handlePresentLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSDictionary *layout = extras[@"layout"];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    [vc setRequestCode:requestCode];
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [[HBDAnimationObserver sharedObserver] beginAnimation];
    [presenting presentViewController:vc animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleShowModalLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    NSDictionary *layout = extras[@"layout"];
    UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc setRequestCode:requestCode];
    [[HBDAnimationObserver sharedObserver] beginAnimation];
    [presenting presentViewController:vc animated:YES completion:^{
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

- (void)invalidate {
    // 
}

@end
