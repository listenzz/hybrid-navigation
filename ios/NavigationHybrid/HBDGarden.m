//
//  HBDGarden.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDGarden.h"
#import <React/RCTConvert.h>
#import <React/RCTEventEmitter.h>

#import "HBDBarButtonItem.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDTitleView.h"
#import "HBDNavigationController.h"


@implementation HBDGarden

static GlobalStyle *globalStyle;

+ (void)createGlobalStyleWithOptions:(NSDictionary *)options {
    globalStyle = [[GlobalStyle alloc] initWithOptions:options];
    [globalStyle inflateNavigationBar:[UINavigationBar appearance]];
    [globalStyle inflateBarButtonItem:[UIBarButtonItem appearance]];
    [globalStyle inflateTabBar:[UITabBar appearance]];
}

+ (GlobalStyle *)globalStyle {
    return globalStyle;
}

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        controller.navigationItem.leftBarButtonItem = [self createBarButtonItem:item forController:controller];
    }
}

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        controller.navigationItem.rightBarButtonItem = [self createBarButtonItem:item forController:controller];
    }
}

- (HBDBarButtonItem *)createBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    HBDBarButtonItem *barButtonItem;
    
    NSDictionary *insetsOption = item[@"insets"];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (insetsOption) {
        insets =  [RCTConvert UIEdgeInsets:insetsOption];
    }

    NSDictionary *icon = item[@"icon"];
    BOOL hasIcon = icon && ![icon isEqual:NSNull.null];
    if (hasIcon) {
        UIImage *iconImage = [HBDUtils UIImage:icon];
        barButtonItem = [[HBDBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain];
        barButtonItem.imageInsets = insets;
    } else {
        NSString *title = item[@"title"];
        barButtonItem = [[HBDBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain];
        [barButtonItem setTitlePositionAdjustment:UIOffsetMake(insets.left, 0) forBarMetrics:UIBarMetricsDefault];
    }
    
    NSNumber *enabled = item[@"enabled"];
    if (enabled) {
        barButtonItem.enabled = [enabled boolValue];
    }
    
    NSString *action = item[@"action"];
    NSString *sceneId = controller.sceneId;
    if (action) {
        barButtonItem.actionBlock = ^{
            RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"NavigationHybrid"];
            [emitter sendEventWithName:@"ON_BAR_BUTTON_ITEM_CLICK" body:@{
                                                                             @"action": action,
                                                                             @"sceneId": sceneId
                                                                             }];
        };
    }
    return barButtonItem;
}

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        NSString *title = item[@"title"];
        controller.navigationItem.title = title;
    } else {
        controller.navigationItem.title = nil;
    }
}

- (void)setHideBackButton:(BOOL)hidden forController:(HBDViewController *)controller {
    controller.navigationItem.hidesBackButton = hidden;
}

- (void)setTopBarStyle:(UIBarStyle)barStyle forController:(HBDViewController *)controller {
    controller.barStyle = barStyle;
    [controller.navigationController.navigationBar setBarStyle:barStyle];
}

- (void)setTopBarAlpha:(float)alpha forController:(HBDViewController *)controller {
    controller.hbd_barAlpha = alpha;
    [controller hbd_setNeedsUpdateNavigationBarAlpha];
}

- (void)setTopBarColor:(UIColor *)color forController:(HBDViewController *)controller {
    controller.hbd_barTintColor = color;
    [controller hbd_setNeedsUpdateNavigationBarColor];
}

- (void)setTopBarShadowHidden:(BOOL)hidden forController:(HBDViewController *)controller {
    controller.hbd_barShadowHidden = hidden;
    [controller hbd_setNeedsUpdateNavigationBarShadowImageAlpha];
}

@end

