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
#import "HBDUtils.h"
#import "HBDEventEmitter.h"


@interface HBDGarden ()

@property(nonatomic, weak, readonly) HBDViewController *viewController;

@end

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

- (instancetype)initWithViewController:(HBDViewController *)vc {
    if (self = [super init]) {
        _viewController = vc;
    }
    return self;
}

- (void)setLeftBarButtonItem:(NSDictionary * __nullable)item {
    if (item) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
            spacer.width = -8;
            [array addObject:spacer];
        }
        
        UIBarButtonItem *buttonItem = [self createBarButtonItem:item];
        UIView *customView = buttonItem.customView;
        if ([customView isKindOfClass:[HBDBarButton class]]) {
            HBDBarButton *button = (HBDBarButton *)customView;
            button.imageEdgeInsets = buttonItem.imageInsets;
            button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, 4, 0, -4);
        }
        [array addObject:buttonItem];
        
        self.viewController.navigationItem.leftBarButtonItems = array;
    } else {
        self.viewController.navigationItem.leftBarButtonItems = nil;
    }
}

- (void)setRightBarButtonItem:(NSDictionary * __nullable)item {
    if (item) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
            spacer.width = -8;
            [array addObject:spacer];
        }
        
        UIBarButtonItem *buttonItem = [self createBarButtonItem:item];
        UIView *customView = buttonItem.customView;
        if ([customView isKindOfClass:[HBDBarButton class]]) {
            HBDBarButton *button = (HBDBarButton *)customView;
            button.imageEdgeInsets = buttonItem.imageInsets;
            button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, -4, 0, 4);
        }
        [array addObject:buttonItem];
        
        self.viewController.navigationItem.rightBarButtonItems = array;
    } else {
        self.viewController.navigationItem.rightBarButtonItems = nil;
    }
}

- (void)setLeftBarButtonItems:(NSArray *)items {
    if (items) {
        NSArray *barButtonItems = [self createBarButtonItems:items];
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
        
        self.viewController.navigationItem.leftBarButtonItems = array;
    }
}

- (void)setRightBarButtonItems:(NSArray *)items {
    if (items) {
        NSArray *barButtonItems = [self createBarButtonItems:items];
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
        
        self.viewController.navigationItem.rightBarButtonItems = array;
    }
}

- (NSArray *)createBarButtonItems:(NSArray *)items {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        [array addObject:[self createBarButtonItem:item]];
    }
    return array;
}

- (HBDBarButtonItem *)createBarButtonItem:(NSDictionary *)item {
    HBDBarButtonItem *barButtonItem;
    
    NSDictionary *insetsOption = item[@"insetsIOS"];
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
    NSString *sceneId = self.viewController.sceneId;
    
    NSString *tintColor = item[@"tintColor"];
    if (tintColor) {
        barButtonItem.tintColor = [HBDUtils colorWithHexString:tintColor];
        UIView *customView = barButtonItem.customView;
        if ([customView isKindOfClass:[HBDBarButton class]]) {
            HBDBarButton *button = (HBDBarButton *)customView;
            button.tintColor = [HBDUtils colorWithHexString:tintColor];
        }
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

- (void)setPassThroughTouches:(BOOL)passThrough {
    if ([self.viewController.view isKindOfClass:[RCTRootView class]]) {
        RCTRootView *rootView = (RCTRootView *)self.viewController.view;
        rootView.passThroughTouches = passThrough;
    }
}

@end

