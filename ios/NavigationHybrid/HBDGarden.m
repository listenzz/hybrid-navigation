//
//  HBDGarden.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDGarden.h"
#import <React/RCTConvert.h>
#import <React/RCTRootView.h>

#import "HBDBarButtonItem.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDTitleView.h"
#import "HBDNavigationController.h"
#import "HBDEventEmitter.h"


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
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
            spacer.width = -8;
            [array addObject:spacer];
        }
        
        UIBarButtonItem *buttonItem = [self createBarButtonItem:item forController:controller];
        UIView *customView = buttonItem.customView;
        if ([customView isKindOfClass:[HBDBarButton class]]) {
            HBDBarButton *button = (HBDBarButton *)customView;
            button.imageEdgeInsets = buttonItem.imageInsets;
            button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, 4, 0, -4);
        }
        [array addObject:buttonItem];
        
        controller.navigationItem.leftBarButtonItems = array;
    }
}

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
            spacer.width = -8;
            [array addObject:spacer];
        }
        
        UIBarButtonItem *buttonItem = [self createBarButtonItem:item forController:controller];
        UIView *customView = buttonItem.customView;
        if ([customView isKindOfClass:[HBDBarButton class]]) {
            HBDBarButton *button = (HBDBarButton *)customView;
            button.imageEdgeInsets = buttonItem.imageInsets;
            button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, -4, 0, 4);
        }
        [array addObject:buttonItem];
        
        controller.navigationItem.rightBarButtonItems = array;
    }
}

- (void)setLeftBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller {
    if (items) {
        NSArray *barButtonItems = [self createBarButtonItems:items forController:controller];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
            spacer.width = -8;
            [array addObject:spacer];
        }
    
        [array addObjectsFromArray:barButtonItems];
        for (NSUInteger i = 0; i < barButtonItems.count; i++) {
            UIBarButtonItem *buttonItem = barButtonItems[i];
            UIView *customView = buttonItem.customView;
            if ([customView isKindOfClass:[HBDBarButton class]]) {
                HBDBarButton *button = (HBDBarButton *)customView;
                button.imageEdgeInsets = buttonItem.imageInsets;
                button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, 4, 0, -4);
            }
        }
        
        controller.navigationItem.leftBarButtonItems = array;
    }
}

- (void)setRightBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller {
    if (items) {
        NSArray *barButtonItems = [self createBarButtonItems:items forController:controller];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
            spacer.width = -8;
            [array addObject:spacer];
        }
        
        [array addObjectsFromArray:barButtonItems];
        for (NSUInteger i = 0; i < barButtonItems.count; i++) {
            UIBarButtonItem *buttonItem = barButtonItems[i];
            UIView *customView = buttonItem.customView;
            if ([customView isKindOfClass:[HBDBarButton class]]) {
                HBDBarButton *button = (HBDBarButton *)customView;
                button.imageEdgeInsets = buttonItem.imageInsets;
                button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, -4, 0, 4);
            }
        }
        
        controller.navigationItem.rightBarButtonItems = array;
    }
}

- (NSArray *)createBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        HBDBarButtonItem *barButtonItem = [self createBarButtonItem:item forController:controller];
        [array addObject:barButtonItem];
    }
    return array;
}

- (HBDBarButtonItem *)createBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    HBDBarButtonItem *barButtonItem;
    
    NSDictionary *insetsOption = item[@"insetsIOS"];
    if (!insetsOption) {
        insetsOption = item[@"insets"];
    }
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (insetsOption) {
        insets =  [RCTConvert UIEdgeInsets:insetsOption];
    }

    NSDictionary *icon = item[@"icon"];
    BOOL hasIcon = icon && ![icon isEqual:NSNull.null];
    if (hasIcon) {
        UIImage *iconImage = [HBDUtils UIImage:icon];
        if (item[@"renderOriginal"] && [item[@"renderOriginal"] boolValue]) {
            iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
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
            [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
               KEY_ON: ON_BAR_BUTTON_ITEM_CLICK,
               KEY_ACTION: action,
               KEY_SCENE_ID: sceneId,
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
    controller.hbd_statusBarHidden = hidden && ![HBDUtils isIphoneX];
    [controller hbd_setNeedsStatusBarHiddenUpdate];
}

- (void)setPassThroughTouches:(BOOL)passThrough forController:(HBDViewController *)controller {
    if ([controller.view isKindOfClass:[RCTRootView class]]) {
        RCTRootView *rootView = (RCTRootView *)controller.view;
        rootView.passThroughTouches = passThrough;
    }
}

@end

