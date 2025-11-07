#import "HBDScreenNavigator.h"

#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"
#import "UIViewController+HBD.h"

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
    if (![presenting canPresentViewController]) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    HBDNavigationController *nav = [[HBDNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    [nav setRequestCode:requestCode];
    [vc setRequestCode:requestCode];
    [vc setPresentingSceneId:presenting.sceneId];

    [presenting presentViewController:nav animated:YES completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleDismissWithViewController:(UIViewController *) vc callback:(RCTResponseSenderBlock)callback {
	BOOL animated = YES;
	if ([vc isKindOfClass:[HBDViewController class]]) {
		HBDViewController *hbdvc = (HBDViewController *)vc;
		animated = hbdvc.animatedTransition;
	}
	
    [vc dismissViewControllerAnimated:animated completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handleShowModalWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    if (![presenting canPresentViewController]) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    UIViewController *vc = [self viewControllerWithExtras:extras];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc setRequestCode:requestCode];
	
	BOOL animated = YES;
	if ([vc isKindOfClass:[HBDViewController class]]) {
		HBDViewController *hbdvc = (HBDViewController *)vc;
		animated = hbdvc.animatedTransition;
	}
	
    [presenting presentViewController:vc animated:animated completion:^{
        callback(@[NSNull.null, @YES]);
    }];
}

- (void)handlePresentLayoutWithViewController:(UIViewController *)presenting extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    NSDictionary *layout = extras[@"layout"];
    NSInteger requestCode = [extras[@"requestCode"] integerValue];
    UIViewController *vc = [[HBDReactBridgeManager get] viewControllerWithLayout:layout];
    [vc setRequestCode:requestCode];
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;

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
