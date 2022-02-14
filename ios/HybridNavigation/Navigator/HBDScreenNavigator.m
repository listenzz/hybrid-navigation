//
//  HBDScreenNavigator.m
//  HybridNavigation
//
//  Created by Listen on 2018/6/28.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDScreenNavigator.h"
#import "HBDReactBridgeManager.h"
#import "HBDNavigationController.h"
#import "HBDModalViewController.h"
#import <React/RCTAssert.h>
#import <React/RCTLog.h>
#import "HBDEventEmitter.h"

@implementation HBDScreenNavigator

- (NSString *)name {
    return @"screen";
}

- (NSArray<NSString *> *)supportActions {
    return @[ @"present", @"presentLayout", @"dismiss", @"showModal", @"showModalLayout", @"hideModal"];
}

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *screen = [layout objectForKey:self.name];
    if (screen) {
        NSString *moduleName = [screen objectForKey:@"moduleName"];
        NSDictionary *props = [screen objectForKey:@"props"];
        NSDictionary *options = [screen objectForKey:@"options"];
        return [[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }
    return nil;
}

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *screen = (HBDViewController *)vc;
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
    if ([vc isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)vc;
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:modal.contentViewController];
    } else if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *)vc;
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    
    if (!target.hbd_viewAppeared) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
        });
        return;
    }
    
    UIViewController *viewController = nil;

    if ([action isEqualToString:@"present"]) {
        viewController = [self createViewControllerWithExtras:extras];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
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
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [target hbd_showViewController:viewController requestCode:requestCode animated:YES completion:^(BOOL finished) {
            resolve(@(finished));
        }];
    } else if ([action isEqualToString:@"hideModal"]) {
        [target hbd_hideViewControllerAnimated:YES completion:^(BOOL finished) {
            resolve(@(finished));
        }];
    } else if ([action isEqualToString:@"presentLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        [viewController setRequestCode:requestCode];
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [target presentViewController:viewController animated:YES completion:^{
            resolve(@(YES));
        }];
    } else if ([action isEqualToString:@"showModalLayout"]) {
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        NSDictionary *layout = [extras objectForKey:@"layout"];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        [target hbd_showViewController:viewController requestCode:requestCode animated:YES completion:^(BOOL finished) {
            resolve(@(finished));
        }];
    }
}

- (UIViewController *)createViewControllerWithExtras:(NSDictionary *)extras {
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    HBDViewController *viewController = nil;
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        viewController = [[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }
    return viewController;
}

@end
