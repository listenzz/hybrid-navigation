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

- (BOOL)buildRouteGraphWithController:(UIViewController *)vc root:(NSMutableArray *)root {
    
    HBDViewController *screen = nil;
    if ([vc isKindOfClass:[HBDViewController class]]) {
        screen = (HBDViewController *)vc;
    } else if ([vc isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)vc;
        screen = (HBDViewController *)modal.contentViewController;
        [[HBDReactBridgeManager sharedInstance] buildRouteGraphWithController:screen root:root];
    }
    
    if (screen) {
        [root addObject:@{
                          @"layout": @"screen",
                          @"sceneId": screen.sceneId,
                          @"moduleName": screen.moduleName,
                          @"mode": [vc hbd_mode],
                          }];
        return YES;
    }
    
    return NO;
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
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
        presented.modalPresentationStyle = UIModalPresentationCurrentContext;
        [presented setRequestCode:requestCode];
        [vc beginAppearanceTransition:NO animated:animated];
        [vc endAppearanceTransition];
        [vc presentViewController:presented animated:animated completion:^{
            
        }];
    } else if ([action isEqualToString:@"dismiss"]) {
        UIViewController *presenting = vc.presentingViewController;
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        // make sure extra lifecycle excuting order
        [vc beginAppearanceTransition:NO animated:animated];
        [vc endAppearanceTransition];
        [presenting dismissViewControllerAnimated:animated completion:^{
            
        }];
    } else if ([action isEqualToString:@"showModal"]) {
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [target setRequestCode:requestCode];
        [vc hbd_showViewController:target requestCode:requestCode animated:YES completion:nil];
    } else if ([action isEqualToString:@"hideModal"]) {
        [vc hbd_hideViewControllerAnimated:YES completion:nil];
    } else if ([action isEqualToString:@"presentLayout"]) {
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        [target setRequestCode:requestCode];
        target.modalPresentationStyle = UIModalPresentationCurrentContext;
        // make sure extra lifecycle excuting order
        [vc beginAppearanceTransition:NO animated:animated];
        [vc endAppearanceTransition];
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
