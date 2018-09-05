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
#import <React/RCTRootView.h>

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

- (void)setLeftBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller {
    if (items) {
        controller.navigationItem.leftBarButtonItems = [self createBarButtonItems:items forController:controller];
    }
}

- (void)setRightBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller {
    if (items) {
        controller.navigationItem.rightBarButtonItems = [self createBarButtonItems:items forController:controller];
    }
}

- (NSArray *)createBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i =0; i < items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        HBDBarButtonItem *barButtonItem = [self createBarButtonItem:item forController:controller];
        [array addObject:barButtonItem];
    }
    return array;
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
    
    NSString *tintColor = item[@"tintColor"];
    if (tintColor) {
        barButtonItem.tintColor = [HBDUtils colorWithHexString:tintColor];
    }
    
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

- (void)setStatusBarHidden:(BOOL)hidden forController:(HBDViewController *)controller {
    controller.hbd_statusBarHidden = hidden;
    [controller setStatusBarHidden:hidden];
}

- (void)setPassThroughTouches:(BOOL)passThrough forController:(HBDViewController *)controller {
    if ([controller.view isKindOfClass:[RCTRootView class]]) {
        RCTRootView *rootView = (RCTRootView *)controller.view;
        rootView.passThroughTouches = passThrough;
    }
}

@end

