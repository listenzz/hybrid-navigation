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

- (void)handlePresentWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    HBDNavigationController *navVC = [[HBDNavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [navVC setRequestCode:requestCode];
    [presenting presentViewController:navVC animated:YES completion:^{
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
    [presenting presentViewController:vc animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handlePresentLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSDictionary *layout = extras[@"layout"];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    UIViewController *viewController = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    [viewController setRequestCode:requestCode];
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [presenting presentViewController:viewController animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleShowModalLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    NSDictionary *layout = extras[@"layout"];
    UIViewController *viewController = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController setRequestCode:requestCode];
    [presenting presentViewController:viewController animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    if (!vc.hbd_inViewHierarchy) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    if (!vc.hbd_viewAppeared) {
        [self performSelector:@selector(handleNavigation:) withObject:@{
            @"viewController": vc,
            @"action": action,
            @"extras": extras,
            @"callback": callback,
        } afterDelay:0.05];
        return;
    }

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

- (UIViewController *)viewControllerWithExtras:(NSDictionary *)extras {
    NSString *moduleName = extras[@"moduleName"];
    if (!moduleName) {
        return nil;
    }
    NSDictionary *props = extras[@"props"];
    NSDictionary *options = extras[@"options"];
    return [[HBDReactBridgeManager get] viewControllerWithModuleName:moduleName props:props options:options];
}

-(void)handleNavigation:(NSDictionary *)params {
    [self handleNavigationWithViewController:params[@"viewController"] action:params[@"action"] extras:params[@"extras"] callback:params[@"callback"]];
}

- (void)invalidate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
