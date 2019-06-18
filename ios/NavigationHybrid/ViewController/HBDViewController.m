//
//  HBDViewController.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDViewController.h"
#import "HBDGarden.h"
#import "HBDUtils.h"
#import "HBDNavigationController.h"
#import <React/RCTLog.h>

@interface HBDViewController ()

@property(nonatomic, copy, readwrite) NSDictionary *props;

@end

@implementation HBDViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
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
    }
    return self;
}

- (void)setAppProperties:(NSDictionary *)props {
    self.props = props;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    NSString *topBarStyle = self.options[@"topBarStyle"];
    if (topBarStyle) {
        return self.hbd_barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
    return [UIApplication sharedApplication].statusBarStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *screenColor = self.options[@"screenBackgroundColor"];
    if (screenColor) {
        self.view.backgroundColor = [HBDUtils colorWithHexString:screenColor];
    } else {
        self.view.backgroundColor = [HBDGarden globalStyle].screenBackgroundColor;
    }
    
    [self applyNavigationBarOptions:self.options];
    
    NSNumber *topBarHidden = self.options[@"topBarHidden"];
    if ([topBarHidden boolValue]) {
        self.hbd_barHidden = YES;
    }
    
    NSNumber *statusBarHidden = self.options[@"statusBarHidden"];
    if (statusBarHidden) {
        self.hbd_statusBarHidden = [statusBarHidden boolValue] && ![HBDUtils isIphoneX];
    }
    
    if ([HBDGarden globalStyle].isBackTitleHidden) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
    
    NSDictionary *titleItem = self.options[@"titleItem"];
    if (titleItem) {
        NSString *moduleName = titleItem[@"moduleName"];
        if (!moduleName) {
            self.navigationItem.title = titleItem[@"title"];
        }
    }
    
    NSDictionary *backItem = self.options[@"backItemIOS"];
    if (!backItem) {
        backItem = self.options[@"backItem"];
    }
    if (backItem) {
        NSString *title = backItem[@"title"];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = title;
        NSString *tintColor = backItem[@"tintColor"];
        if (tintColor) {
            backButton.tintColor = [HBDUtils colorWithHexString:tintColor];
        }
        self.navigationItem.backBarButtonItem = backButton;
    }
    
    NSNumber *interactive = self.options[@"backInteractive"];
    if (interactive) {
        self.hbd_backInteractive = [interactive boolValue];
    }
    
    NSNumber *swipeBackEnabled = self.options[@"swipeBackEnabled"];
    if (swipeBackEnabled) {
        self.hbd_swipeBackEnabled = [swipeBackEnabled boolValue];
    }
    
    NSNumber *extendedLayoutIncludesTopBar = self.options[@"extendedLayoutIncludesTopBar"];
    if (extendedLayoutIncludesTopBar) {
        self.hbd_extendedLayoutIncludesTopBar = [extendedLayoutIncludesTopBar boolValue];
    }
    
    if (!(self.hbd_extendedLayoutIncludesTopBar || hasAlpha(self.hbd_barTintColor))) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    HBDGarden *garden = [[HBDGarden alloc] init];
    
    NSDictionary *rightBarButtonItem = self.options[@"rightBarButtonItem"];
    [garden setRightBarButtonItem:rightBarButtonItem forController:self];
    
    NSDictionary *leftBarButtonItem = self.options[@"leftBarButtonItem"];
    [garden setLeftBarButtonItem:leftBarButtonItem forController:self];
    
    NSArray *rightBarButtonItems = self.options[@"rightBarButtonItems"];
    [garden setRightBarButtonItems:rightBarButtonItems forController:self];
    
    NSArray *leftBarButtonItems = self.options[@"leftBarButtonItems"];
    [garden setLeftBarButtonItems:leftBarButtonItems forController:self];
}

- (void)updateNavigationBar:(NSDictionary *)options {
    [self applyNavigationBarOptions:options];
    [self hbd_setNeedsUpdateNavigationBar];
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
    
    NSMutableDictionary *titleAttributes = [self.hbd_titleTextAttributes mutableCopy];
    if (!titleAttributes) {
        titleAttributes = [@{} mutableCopy];
    }
    NSString *titleTextColor = [options objectForKey:@"titleTextColor"];
    NSNumber *titleTextSize = [options objectForKey:@"titleTextSize"];
    if (titleTextColor) {
        [titleAttributes setObject:[HBDUtils colorWithHexString:titleTextColor] forKey:NSForegroundColorAttributeName];
    }
    if (titleTextSize) {
        [titleAttributes setObject:[UIFont systemFontOfSize:[titleTextSize floatValue]] forKey:NSFontAttributeName];
    }
    self.hbd_titleTextAttributes = titleAttributes;
    
    NSString *topBarColor = options[@"topBarColor"];
    if (topBarColor) {
        self.hbd_barTintColor = [HBDUtils colorWithHexString:topBarColor];
    }
    
    NSNumber *topBarAlpha = options[@"topBarAlpha"];
    if (topBarAlpha) {
        self.hbd_barAlpha = [topBarAlpha floatValue];
    }
    
    NSNumber *hideShadow = options[@"topBarShadowHidden"];
    if (hideShadow) {
        self.hbd_barShadowHidden = [hideShadow boolValue];
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
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

@end
