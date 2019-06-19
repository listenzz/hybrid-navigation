//
//  HBDTabBarController.m
//  NavigationHybrid
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

@interface HBDTabBarController () <UITabBarControllerDelegate, RCTRootViewDelegate>

@property (nonatomic, strong) RCTRootView *rootView;
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
    NSString *tabBarSelectedItemColor = options[@"tabBarSelectedItemColor"];
    NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
    if (tabBarItemColor) {
        props[@"itemColor"] = tabBarItemColor;
        if (tabBarSelectedItemColor) {
            props[@"selectedItemColor"] = tabBarSelectedItemColor;
        }
        if (tabBarUnselectedItemColor) {
            props[@"itemColor"] = tabBarUnselectedItemColor;
            props[@"selectedItemColor"] = tabBarItemColor;
        }
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
            tab[@"dotBadge"] = @(dot);
            tab[@"remind"] = @(dot);
            tab[@"badgeText"] = text ?: NSNull.null;
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

- (NSMutableDictionary *)tabAtIndex:(NSInteger)index {
    NSMutableDictionary *options = [self.tabBarOptions mutableCopy];
    NSMutableArray *tabs = [options[@"tabs"] mutableCopy];
    options[@"tabs"] = tabs;
    NSMutableDictionary *tab = [tabs[index] mutableCopy];
    tabs[index] = tab;
    self.tabBarOptions = options;
    return tab;
}

- (void)updateTabBarItem:(NSDictionary *)tabItem atIndex:(NSInteger)index {
    if (self.hasCustomTabBar) {
        NSMutableDictionary *tab = [self tabAtIndex:index];
        tab[@"icon"] = [HBDUtils iconUriFromUri:tabItem[@"icon"][@"uri"]];
        tab[@"selectedIcon"] = [HBDUtils iconUriFromUri:tabItem[@"selectedIcon"][@"uri"]];
        self.rootView.appProperties = [self props];
    } else {
        UIViewController *tab = [self.viewControllers objectAtIndex:index];
        [tab hbd_updateTabBarItem:tabItem];
    }
}

- (void)updateTabBar:(NSDictionary *)options {
    UITabBar *tabBar = self.tabBar;
    NSString *tabBarColor = [options objectForKey:@"tabBarColor"];
    if (tabBarColor) {
        [tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]]];
    }
    
    NSDictionary *tabBarShadowImage = options[@"tabBarShadowImage"];
    if (tabBarShadowImage && ![tabBarShadowImage isEqual:NSNull.null]) {
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
    if (tabBarItemColor && tabBarUnselectedItemColor) {
        if (self.hasCustomTabBar) {
            NSMutableDictionary *options = [self.tabBarOptions mutableCopy];
            options[@"tabBarItemColor"] = tabBarItemColor;
            options[@"tabBarUnselectedItemColor"] = tabBarUnselectedItemColor ?: NSNull.null;
            self.tabBarOptions = options;
            self.rootView.appProperties = [self props];
        } else {
             tabBar.tintColor = [HBDUtils colorWithHexString:tabBarItemColor];
            if (@available(iOS 10.0, *)) {
                tabBar.unselectedItemTintColor = [HBDUtils colorWithHexString:tabBarUnselectedItemColor];
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
                                                           KEY_RESULT_DATA: data ?: [NSNull null],
                                                           KEY_SCENE_ID: self.sceneId,
                                                           }];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    if (self.hasCustomTabBar && self.rootView) {
        NSMutableDictionary *props = [[self props] mutableCopy];
        props[@"selectedIndex"] = @(selectedIndex);
        self.rootView.appProperties = props;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    UIViewController *selectedVC = self.selectedViewController;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)selectedVC;
        selectedVC = nav.viewControllers[0];
    }
    
    HBDReactViewController *selectedReactVC = nil;
    if ([selectedVC isKindOfClass:[HBDReactViewController class]]) {
        selectedReactVC = (HBDReactViewController *)selectedVC;
    }
    
    if (!selectedReactVC || !self.intercepted) {
        return YES;
    }
    
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        viewController = nav.viewControllers[0];
    }
    
    HBDReactViewController *reactVC = nil;
    if ([viewController isKindOfClass:[HBDReactViewController class]]) {
        reactVC = (HBDReactViewController *)viewController;
    }
    
    [HBDEventEmitter sendEvent:EVENT_SWITCH_TAB data:@{
                                                       KEY_SCENE_ID: selectedReactVC.sceneId,
                                                       KEY_MODULE_NAME: reactVC.moduleName?: NSNull.null,
                                                       KEY_INDEX: @(index)
                                                       }];
    return NO;
}

@end
