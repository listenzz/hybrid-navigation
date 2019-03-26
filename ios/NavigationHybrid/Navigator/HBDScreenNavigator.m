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
    
    if ([vc isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)vc;
        [[HBDReactBridgeManager sharedInstance] buildRouteGraphWithController:modal.contentViewController root:root];
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
        return [[HBDReactBridgeManager sharedInstance] primaryViewControllerWithViewController:modal.contentViewController];
    } else if ([vc isKindOfClass:[HBDViewController class]]) {
        return (HBDViewController *)vc;
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras {
    HBDViewController *viewController = nil;
    NSString *moduleName = [extras objectForKey:@"moduleName"];
    if (moduleName) {
        NSDictionary *props = [extras objectForKey:@"props"];
        NSDictionary *options = [extras objectForKey:@"options"];
        viewController =[[HBDReactBridgeManager sharedInstance] controllerWithModuleName:moduleName props:props options:options];
    }
    
    if ([action isEqualToString:@"present"]) {
        if (![self canPresentFromViewController:target]) {
            return;
        }
        
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        HBDNavigationController *navVC = [[HBDNavigationController alloc] initWithRootViewController:viewController];
        navVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [navVC setRequestCode:requestCode];
        [target beginAppearanceTransition:NO animated:animated];
        [target endAppearanceTransition];
        [target presentViewController:navVC animated:animated completion:^{
            
        }];
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
        if (![self canShowModalFromViewController:target]) {
            return;
        }

        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [viewController setRequestCode:requestCode];
        [target hbd_showViewController:viewController requestCode:requestCode animated:YES completion:nil];
    } else if ([action isEqualToString:@"hideModal"]) {
        [target hbd_hideViewControllerAnimated:YES completion:nil];
    } else if ([action isEqualToString:@"presentLayout"]) {
        if (![self canPresentFromViewController:target]) {
            return;
        }
        
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        BOOL animated = [[extras objectForKey:@"animated"] boolValue];
        [target setRequestCode:requestCode];
        target.modalPresentationStyle = UIModalPresentationCurrentContext;
        // make sure extra lifecycle excuting order
        [target beginAppearanceTransition:NO animated:animated];
        [target endAppearanceTransition];
        [target presentViewController:target animated:animated completion:^{
            
        }];
    } else if ([action isEqualToString:@"showModalLayout"]) {
        if (![self canShowModalFromViewController:target]) {
            return;
        }
        
        NSDictionary *layout = [extras objectForKey:@"layout"];
        UIViewController *target = [[HBDReactBridgeManager sharedInstance] controllerWithLayout:layout];
        NSInteger requestCode = [[extras objectForKey:@"requestCode"] integerValue];
        [target setRequestCode:requestCode];
        [target hbd_showViewController:target animated:YES completion:^(BOOL finished) {
            
        }];
    }
}

- (BOOL)canPresentFromViewController:(UIViewController *)target {
    UIViewController *presented = target.presentedViewController;
    if (presented && !presented.isBeingDismissed) {
        RCTLogWarn(@"can not present since the scene had present another scene already.");
        return NO;
    }
    
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        UIViewController *viewController = window.rootViewController;
        if ([viewController isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)viewController;
            if (!modal.beingHidden) {
                RCTLogWarn(@"can not present a scene over a modal.");
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)canShowModalFromViewController:(UIViewController *)target {
    UIViewController *presented = target.presentedViewController;
    if (presented && !presented.isBeingDismissed) {
        RCTLogWarn(@"can not show modal since the scene had present another scene already.");
        return NO;
    }
    
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        UIViewController *viewController = window.rootViewController;
        if ([viewController isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)viewController;
            if (!modal.beingHidden && window != target.view.window) {
                RCTLogWarn(@"can not show modal since the scene had show another modal already.");
                return NO;
            }
        }
    }
    
    return YES;
}

@end
