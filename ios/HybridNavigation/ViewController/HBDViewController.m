//
//  HBDViewController.m
//  HybridNavigation
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <React/RCTLog.h>

#import "HBDViewController.h"
#import "HBDViewController+Garden.h"
#import "HBDUtils.h"
#import "GlobalStyle.h"

@interface HBDViewController ()

@property(nonatomic, copy, readwrite) NSDictionary *props;
@property(nonatomic, copy, readwrite) NSDictionary *options;

@end

@implementation HBDViewController

- (void)dealloc {
    RCTLogInfo(@"[Navigator] %s", __FUNCTION__);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithModuleName:nil props:nil options:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithModuleName:nil props:nil options:nil];
}

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _moduleName = moduleName;
        _options = options;
        _props = props;
        
        self.forceTransparentDialogWindow = [options[@"forceTransparentDialogWindow"] boolValue];
        [self applyNavigationBarOptions:options];
        [self applyTabBarOptions:options];
    }
    return self;
}

- (void)setAppProperties:(NSDictionary *)props {
    self.props = props;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.hbd_barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    if (@available(iOS 13.0, *)) {
        return [self hbd_statusBarHidden] && ![HBDUtils isInCall];
    }

    if ([HBDUtils isIphoneX]) {
        return [self hbd_statusBarHidden] && ![HBDUtils isInCall];
    } else {
        UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
        BOOL hidden = [self hbd_statusBarHidden] && ![HBDUtils isInCall];
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        statusBar.transform = hidden ? CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -statusBarHeight) : CGAffineTransformIdentity;
        statusBar.alpha = hidden ? 0 : 1.0;
        return NO;
    }
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.options[@"homeIndicatorAutoHiddenIOS"]) {
        return [self.options[@"homeIndicatorAutoHiddenIOS"] boolValue];
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![HBDUtils isIphoneX]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![HBDUtils isIphoneX]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
}

- (void)statusBarFrameWillChange:(NSNotification *)notification {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *screenColor = self.options[@"screenBackgroundColor"];
    if (screenColor) {
        self.view.backgroundColor = [HBDUtils colorWithHexString:screenColor];
    } else {
        self.view.backgroundColor = [GlobalStyle globalStyle].screenBackgroundColor;
    }
}

- (void)applyTabBarOptions:(NSDictionary *)options {
    NSDictionary *tabItem = options[@"tabItem"];
    if (tabItem) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        tabBarItem.title = tabItem[@"title"];
        NSDictionary *unselectedIcon = tabItem[@"unselectedIcon"];
        if (unselectedIcon) {
            tabBarItem.selectedImage = [[HBDUtils UIImage:tabItem[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tabBarItem.image = [[HBDUtils UIImage:unselectedIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            tabBarItem.image = [HBDUtils UIImage:tabItem[@"icon"]];
        }
        self.tabBarItem = tabBarItem;
    }
}

- (void)applyNavigationBarOptions:(NSDictionary *)options {
    NSString *topBarStyle = options[@"topBarStyle"];
    if (topBarStyle) {
        if ([topBarStyle isEqualToString:@"dark-content"]) {
            self.hbd_barStyle = UIBarStyleDefault;
        } else {
            self.hbd_barStyle = UIBarStyleBlack;
        }
    }

    NSString *topBarTintColor = options[@"topBarTintColor"];
    if (topBarTintColor) {
        self.hbd_tintColor = [HBDUtils colorWithHexString:topBarTintColor];
    }

    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
    NSString *titleTextColor = options[@"titleTextColor"];
    NSNumber *titleTextSize = options[@"titleTextSize"];
    if (titleTextColor) {
        titleAttributes[NSForegroundColorAttributeName] = [HBDUtils colorWithHexString:titleTextColor];
    }
    if (titleTextSize) {
        titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:[titleTextSize floatValue]];
    }

    if (titleAttributes.count > 0) {
        if (self.hbd_titleTextAttributes) {
            NSMutableDictionary *attributes = [self.hbd_titleTextAttributes mutableCopy];
            [attributes addEntriesFromDictionary:titleAttributes];
            self.hbd_titleTextAttributes = attributes;
        } else {
            self.hbd_titleTextAttributes = titleAttributes;
        }
    }

    NSString *topBarColor = options[@"topBarColor"];
    if (topBarColor) {
        self.hbd_barTintColor = [HBDUtils colorWithHexString:topBarColor];
    }

    NSNumber *topBarAlpha = options[@"topBarAlpha"];
    if (topBarAlpha) {
        self.hbd_barAlpha = [topBarAlpha floatValue];
    }

    NSNumber *topBarHidden = options[@"topBarHidden"];
    if ([topBarHidden boolValue]) {
        self.hbd_barHidden = YES;
    }

    if ([GlobalStyle globalStyle].isBackTitleHidden) {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem = buttonItem;
    }

    NSDictionary *backItem = options[@"backItemIOS"];
    if (backItem) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = backItem[@"title"];
        NSString *tintColor = backItem[@"tintColor"];
        if (tintColor) {
            backButton.tintColor = [HBDUtils colorWithHexString:tintColor];
        }
        self.navigationItem.backBarButtonItem = backButton;
    }

    NSNumber *swipeBackEnabled = options[@"swipeBackEnabled"];
    if (swipeBackEnabled) {
        self.hbd_swipeBackEnabled = [swipeBackEnabled boolValue];
    }

    NSNumber *extendedLayoutIncludesTopBar = options[@"extendedLayoutIncludesTopBar"];
    if (extendedLayoutIncludesTopBar) {
        self.extendedLayoutIncludesOpaqueBars = [extendedLayoutIncludesTopBar boolValue];
    }

    NSNumber *hideShadow = options[@"topBarShadowHidden"];
    if (hideShadow) {
        self.hbd_barShadowHidden = [hideShadow boolValue];
    }

    NSNumber *statusBarHidden = options[@"statusBarHidden"];
    if (statusBarHidden) {
        self.hbd_statusBarHidden = [statusBarHidden boolValue];
    }

    NSNumber *backInteractive = options[@"backInteractive"];
    if (backInteractive) {
        self.hbd_backInteractive = [backInteractive boolValue];
    }

    NSNumber *backButtonHidden = options[@"backButtonHidden"];
    if (backButtonHidden) {
        if ([backButtonHidden boolValue]) {
            if (@available(iOS 11, *)) {
                [self.navigationItem setHidesBackButton:YES];
            } else {
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
            }
        } else {
            if (@available(iOS 11, *)) {
                [self.navigationItem setHidesBackButton:NO];
            } else {
                self.navigationItem.leftBarButtonItem = nil;
            }
        }
    }

    NSDictionary *titleItem = options[@"titleItem"];
    if (titleItem) {
        NSString *moduleName = titleItem[@"moduleName"];
        if (!moduleName) {
            self.navigationItem.title = titleItem[@"title"];
        }
    }

    id rightBarButtonItem = options[@"rightBarButtonItem"];
    if (rightBarButtonItem) {
        [self setRightBarButtonItem:RCTNilIfNull(rightBarButtonItem)];
    }

    id leftBarButtonItem = options[@"leftBarButtonItem"];
    if (leftBarButtonItem) {
        [self setLeftBarButtonItem:RCTNilIfNull(leftBarButtonItem)];
    }

    NSArray *rightBarButtonItems = options[@"rightBarButtonItems"];
    if (rightBarButtonItems) {
        [self setRightBarButtonItems:rightBarButtonItems];
    }

    NSArray *leftBarButtonItems = options[@"leftBarButtonItems"];
    if (leftBarButtonItems) {
        [self setLeftBarButtonItems:leftBarButtonItems];
    }
}

- (void)updateNavigationBarOptions:(NSDictionary *)options {
    NSDictionary *previous = self.options;
    self.options = [HBDUtils mergeItem:options withTarget:previous];

    NSMutableDictionary *target = [options mutableCopy];

    if (options[@"titleItem"]) {
        target[@"titleItem"] = self.options[@"titleItem"];
    }

    if (options[@"leftBarButtonItem"]) {
        target[@"leftBarButtonItem"] = self.options[@"leftBarButtonItem"];
    }

    if (options[@"rightBarButtonItem"]) {
        target[@"rightBarButtonItem"] = self.options[@"rightBarButtonItem"];
    }

    if (options[@"leftBarButtonItems"]) {
        target[@"leftBarButtonItems"] = self.options[@"leftBarButtonItems"];
    }

    if (options[@"rightBarButtonItems"]) {
        target[@"rightBarButtonItems"] = self.options[@"rightBarButtonItems"];
    }

    [self applyNavigationBarOptions:target];

    NSString *screenColor = options[@"screenBackgroundColor"];
    if (screenColor && [self isViewLoaded]) {
        self.view.backgroundColor = [HBDUtils colorWithHexString:screenColor];
    }

    NSNumber *statusBarHidden = options[@"statusBarHidden"];
    if (statusBarHidden) {
        [self setNeedsStatusBarAppearanceUpdate];
    }

    if (options[@"homeIndicatorAutoHiddenIOS"]) {
        if (@available(iOS 11.0, *)) {
            [self setNeedsUpdateOfHomeIndicatorAutoHidden];
        }
    }

    NSNumber *passThroughTouches = options[@"passThroughTouches"];
    if (passThroughTouches) {
        [self setPassThroughTouches:[passThroughTouches boolValue]];
    }

    if ([self shouldUpdateNavigationBar:options compareTo:previous]) {
        [self hbd_setNeedsUpdateNavigationBar];
    }
}

- (BOOL)shouldUpdateNavigationBar:(NSDictionary *)options compareTo:(NSDictionary *)previous {
    NSArray *keys = @[@"topBarStyle", @"topBarColor", @"topBarAlpha", @"tintColor", @"topBarShadowHidden"];
    for (NSString *opt in options.allKeys) {
        if ([keys containsObject:opt] && [NSString stringWithFormat:@"%@", previous[opt]] != [NSString stringWithFormat:@"%@", options[opt]]) {
            return YES;
        }
    }
    return NO;
}

@end
