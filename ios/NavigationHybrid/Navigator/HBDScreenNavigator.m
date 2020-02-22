//
//  HBDScreenNavigator.m
//  NavigationHybrid
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

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc root:(NSMutableArray *)root {
    
    if ([vc isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)vc;
        [[HBDReactBridgeManager get] buildRouteGraphWithController:modal.contentViewController root:root];
        return YES;
    }
    
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *screen = (HBDViewController *)vc;
        [root addObject:@{
                          @"layout": @"screen",
                          @"sceneId": screen.sceneId,
                          @"moduleName": screen.moduleName ?: NSNull.null,
                          @"mode": [vc hbd_mode],
                          }];
        return YES;
    }

    return NO;
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

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras {
    UIViewController *viewController = nil;
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        viewController =[[HBDReactBridgeManager get] controllerWithModuleName:moduleName props:props options:options];
    }
    
    if ([action isEqualToString:@"present"]) {
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        HBDNavigationController *navVC = [[HBDNavigationController alloc] initWithRootViewController:viewController];
        navVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [navVC setRequestCode:requestCode];
        [target beginAppearanceTransition:NO animated:animated];
        [target endAppearanceTransition];
        [target presentViewController:navVC animated:animated completion:NULL];
    } else if ([action isEqualToString:@"dismiss"]) {
        UIViewController *presenting = target.presentingViewController;
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        // make sure extra lifecycle excuting order
        [target beginAppearanceTransition:NO animated:animated];
        [target endAppearanceTransition];
        if (presenting) {
            [presenting dismissViewControllerAnimated:animated completion:NULL];
        } else {
            [target dismissViewControllerAnimated:animated completion:NULL];
        }
    } else if ([action isEqualToString:@"showModal"]) {
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [target hbd_showViewController:viewController requestCode:requestCode animated:YES completion:NULL];
    } else if ([action isEqualToString:@"hideModal"]) {
        [target hbd_hideViewControllerAnimated:YES completion:nil];
    } else if ([action isEqualToString:@"presentLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        [viewController setRequestCode:requestCode];
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [target beginAppearanceTransition:NO animated:animated];
        [target endAppearanceTransition];
        [target presentViewController:viewController animated:animated completion:NULL];
    } else if ([action isEqualToString:@"showModalLayout"]) {
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        NSDictionary *layout = [extras objectForKey:@"layout"];
        viewController = [[HBDReactBridgeManager get] controllerWithLayout:layout];
        [target hbd_showViewController:viewController requestCode:requestCode animated:YES completion:NULL];
    }
}

@end
