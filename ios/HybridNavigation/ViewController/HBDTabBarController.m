//
//  HBDTabBarController.m
//  HybridNavigation
//
//  Created by Listen on 2018/1/30.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDTabBarController.h"
#import "HBDReactViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "UITabBar+Badge.h"
#import "HBDEventEmitter.h"
#import "HBDReactTabBar.h"
#import "HBDRootView.h"

#import <React/RCTRootView.h>
#import <React/RCTRootViewDelegate.h>
#import <React/RCTLog.h>

@interface HBDTabBarController () <UITabBarControllerDelegate, RCTRootViewDelegate>

@property(nonatomic, strong) RCTRootView *rootView;
@property(nonatomic, copy) NSDictionary *tabBarOptions;
@property(nonatomic, assign) BOOL hasCustomTabBar;

@end

@implementation HBDTabBarController

- (instancetype)initWithTabBarOptions:(NSDictionary *)options {
    self.tabBarOptions = options;
    self.hasCustomTabBar = YES;
    return [super init];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    self.delegate = self;
    self.intercepted = YES;
    if (self.hasCustomTabBar) {
        [self setValue:[[HBDReactTabBar alloc] init] forKey:@"tabBar"];
        [self customTabBar];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.hasCustomTabBar) {
        [self removeTabBarAboriginal];
        [self.tabBar bringSubviewToFront:self.rootView];
    }
}

- (void)customTabBar {
    NSString *moduleName = self.tabBarOptions[@"tabBarModuleName"];
    NSMutableDictionary *props = [[self props] mutableCopy];
    props[@"selectedIndex"] = self.tabBarOptions[@"selectedIndex"];
    RCTRootView *rootView = [[HBDRootView alloc] initWithBridge:[HBDReactBridgeManager get].bridge moduleName:moduleName initialProperties:props];
    rootView.backgroundColor = UIColor.clearColor;
    
    BOOL sizeIndeterminate = [self.tabBarOptions[@"sizeIndeterminate"] boolValue];
    if (sizeIndeterminate) {
        rootView.delegate = self;
        rootView.passThroughTouches = YES;
        rootView.sizeFlexibility = RCTRootViewSizeFlexibilityWidthAndHeight;
    } else {
        rootView.frame = CGRectMake(0, 1, CGRectGetWidth(self.tabBar.bounds), 48);
    }
    [self.tabBar addSubview:rootView];
    self.rootView = rootView;
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    CGFloat width = rootView.intrinsicContentSize.width;
    CGFloat height = rootView.intrinsicContentSize.height;
    CGRect frame = CGRectMake(0, 48 - height, width, height);
    self.rootView.frame = frame;
}

- (NSDictionary *)props {
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    NSDictionary *options = self.tabBarOptions;
    props[@"sceneId"] = self.sceneId;
    props[@"tabs"] = options[@"tabs"];
    props[@"selectedIndex"] = @(self.selectedIndex);
    props[@"badgeColor"] = options[@"badgeColor"];
    
    NSString *tabBarItemColor = options[@"tabBarItemColor"];
    NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
    if (tabBarItemColor) {
        props[@"itemColor"] = tabBarItemColor;
        props[@"unselectedItemColor"] = RCTNullIfNil(tabBarUnselectedItemColor);
    }
    return props;
}

- (void)removeTabBarAboriginal {
    NSUInteger count = self.tabBar.subviews.count;
    for (NSInteger i = count -1; i > -1; i --) {
        UIView *view = self.tabBar.subviews[i];
        NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([viewName isEqualToString:@"UITabBarButton"]) {
            [view removeFromSuperview];
        }
    }
}

- (void)setTabBadge:(NSArray<NSDictionary *> *)options {
    for (NSDictionary *option in options) {
        NSUInteger index = option[@"index"] ? [option[@"index"] integerValue] : 0;
        BOOL hidden = option[@"hidden"] ? [option[@"hidden"] boolValue] : YES;
        
        NSString *text = hidden ? nil : (option[@"text"] ? option[@"text"] : nil);
        BOOL dot = hidden ?  NO : (option[@"dot"] ? [option[@"dot"] boolValue] : NO);
        
        if (self.hasCustomTabBar) {
            NSMutableDictionary *tab = [self tabAtIndex:index];
            tab[@"dot"] = @(dot);
            tab[@"badgeText"] = RCTNullIfNil(text);
        } else {
            UIViewController *vc = self.viewControllers[index];
            vc.tabBarItem.badgeValue = text;
            UITabBar *tabBar = self.tabBar;
            if (dot) {
                [tabBar showDotBadgeAtIndex:index];
            } else {
                [tabBar hideDotBadgeAtIndex:index];
            }
        }
    }
    
    if (self.hasCustomTabBar) {
        self.rootView.appProperties = [self props];
    }
}

- (void)setTabIcon:(NSArray<NSDictionary *> *)options {
    for (NSDictionary *option in options) {
        NSUInteger index = option[@"index"] ? [option[@"index"] integerValue] : 0;
        if (self.hasCustomTabBar) {
            NSMutableDictionary *tab = [self tabAtIndex:index];
            tab[@"icon"] = [HBDUtils iconUriFromUri:option[@"icon"][@"uri"]];
            tab[@"unselectedIcon"] = RCTNullIfNil([HBDUtils iconUriFromUri:option[@"unselectedIcon"][@"uri"]]);
        } else {
            UIViewController *tab = [self.viewControllers objectAtIndex:index];
            [tab hbd_updateTabBarItem:option];
        }
    }
    
    if (self.hasCustomTabBar) {
        self.rootView.appProperties = [self props];
    }
}

- (NSMutableDictionary *)tabAtIndex:(NSInteger)index {
    NSMutableDictionary *options = [self.tabBarOptions mutableCopy];
    NSMutableArray *tabs = [options[@"tabs"] mutableCopy];
    options[@"tabs"] = tabs;
    NSMutableDictionary *tab = [tabs[index] mutableCopy];
    tabs[index] = tab;
    self.tabBarOptions = options;
    return tab;
}

- (void)updateTabBar:(NSDictionary *)options {
    UITabBar *tabBar = self.tabBar;
    NSString *tabBarColor = [options objectForKey:@"tabBarColor"];
    if (tabBarColor) {
        [tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]]];
    }
    
    NSDictionary *tabBarShadowImage = options[@"tabBarShadowImage"];
    if (RCTNilIfNull(tabBarShadowImage)) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = tabBarShadowImage[@"image"];
        NSString *color = tabBarShadowImage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        tabBar.shadowImage = image;
    }
    
    NSString *tabBarItemColor = options[@"tabBarItemColor"];
    NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
    if (tabBarItemColor) {
        if (self.hasCustomTabBar) {
            NSMutableDictionary *options = [self.tabBarOptions mutableCopy];
            options[@"tabBarItemColor"] = tabBarItemColor;
            options[@"tabBarUnselectedItemColor"] = RCTNullIfNil(tabBarUnselectedItemColor);
            self.tabBarOptions = options;
            self.rootView.appProperties = [self props];
        } else {
             tabBar.tintColor = [HBDUtils colorWithHexString:tabBarItemColor];
            if (@available(iOS 10.0, *)) {
                if (tabBarUnselectedItemColor) {
                    tabBar.unselectedItemTintColor = [HBDUtils colorWithHexString:tabBarUnselectedItemColor];
                }
            }
        }
    }
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    if (self.hasCustomTabBar) {
        [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                                                           KEY_ON: ON_COMPONENT_RESULT,
                                                           KEY_REQUEST_CODE: @(requestCode),
                                                           KEY_RESULT_CODE: @(resultCode),
                                                           KEY_RESULT_DATA: RCTNullIfNil(data),
                                                           KEY_SCENE_ID: self.sceneId,
                                                           }];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedViewController:self.viewControllers[selectedIndex]];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    [super setSelectedViewController:selectedViewController];

    if (self.hasCustomTabBar && self.rootView) {
        NSMutableDictionary *props = [[self props] mutableCopy];
        props[@"selectedIndex"] = @(index);
        self.rootView.appProperties = props;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([[HBDReactBridgeManager get] hasRootLayout] && self.intercepted) {
        NSInteger from = self.selectedIndex;
        NSInteger to = [self.childViewControllers indexOfObject:viewController];
        
        [HBDEventEmitter sendEvent:EVENT_SWITCH_TAB data:@{
            KEY_SCENE_ID: self.sceneId,
            KEY_INDEX: [NSString stringWithFormat:@"%d-%d", from, to],
        }];
        return NO;
    }
    return YES;
}

@end
