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
        return [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
    }
    return nil;
}

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc graph:(NSMutableArray *)container {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *screen = nil;
        if ([vc isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)vc;
            screen = (HBDViewController *)modal.contentViewController;
            [[HBDReactBridgeManager sharedInstance] routeGraphWithController:screen container:container];
        } else {
            screen = (HBDViewController *)vc;
            [container addObject:@{
                                   @"type": @"screen",
                                   @"screen": @{ @"moduleName": screen.moduleName, @"sceneId": screen.sceneId}
                                   }];
        }
        return YES;
    }
    return NO;
}

- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc {
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *)vc;
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras {
    HBDViewController *target = nil;
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        target =[[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
    }
    
    if ([action isEqualToString:@"present"]) {
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        HBDNavigationController *presented = [[HBDNavigationController alloc] initWithRootViewController:target];
        [presented setRequestCode:requestCode];
        [vc presentViewController:presented animated:animated completion:^{
            
        }];
    } else if ([action isEqualToString:@"dismiss"]) {
        UIViewController *presenting = vc.presentingViewController;
        if (presenting) {
            [presenting didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:vc.requestCode];
        }
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        [presenting dismissViewControllerAnimated:animated completion:^{
            
        }];
    } else if ([action isEqualToString:@"showModal"]) {
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [target setRequestCode:requestCode];
        [vc hbd_showViewController:target animated:YES completion:^(BOOL finished) {
            
        }];
    } else if ([action isEqualToString:@"hideModal"]) {
        UIViewController *target = vc.hbd_targetViewController;
        if (target) {
            [target didReceiveResultCode:vc.resultCode resultData:vc.resultData requestCode:vc.requestCode];
        }
        [target hbd_hideViewControllerAnimated:YES completion:^(BOOL finished) {
            
        }];
    } else if ([action isEqualToString:@"presentLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        [target setRequestCode:requestCode];
        [vc presentViewController:target animated:animated completion:^{
            
        }];
    } else if ([action isEqualToString:@"showModalLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [target setRequestCode:requestCode];
        [vc hbd_showViewController:target animated:YES completion:^(BOOL finished) {
            
        }];
    }
}

@end
