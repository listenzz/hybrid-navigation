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

BOOL hasAlpha(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green= 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha < 1.0;
}

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
        _sceneId = [[NSUUID UUID] UUIDString];
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
    if (self.hbd_barStyle) {
        return self.hbd_barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
    return [UIApplication sharedApplication].statusBarStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *screenColor = self.options[@"screenColor"];
    if (screenColor) {
        self.view.backgroundColor = [HBDUtils colorWithHexString:screenColor];
    } else {
        self.view.backgroundColor = [HBDGarden globalStyle].screenBackgroundColor;
    }
    
    NSString *topBarStyle = self.options[@"topBarStyle"];
    if (topBarStyle) {
        if ([topBarStyle isEqualToString:@"dark-content"]) {
            self.hbd_barStyle = UIBarStyleDefault;
        } else {
            self.hbd_barStyle = UIBarStyleBlack;
        }
    }
    
    NSString *topBarColor = self.options[@"topBarColor"];
    if (topBarColor) {
        self.hbd_barTintColor = [HBDUtils colorWithHexString:topBarColor];
    }
    
    NSString *topBarTintColor = self.options[@"topBarTintColor"];
    if (topBarTintColor) {
        self.hbd_tintColor = [HBDUtils colorWithHexString:topBarTintColor];
    }
    
    NSString *titleTextColor = self.options[@"titleTextColor"];
    if (titleTextColor) {
        NSMutableDictionary *attribute = [[UINavigationBar appearance].titleTextAttributes mutableCopy];
        if (!attribute) {
            attribute = [@{} mutableCopy];
        }
        [attribute setObject:[HBDUtils colorWithHexString:titleTextColor] forKey:NSForegroundColorAttributeName];
        self.hbd_titleTextAttributes = attribute;
    }
    
    NSNumber *topBarAlpha = self.options[@"topBarAlpha"];
    if (topBarAlpha) {
        self.hbd_barAlpha = [topBarAlpha floatValue];
    }
    
    NSNumber *hideShadow = self.options[@"topBarShadowHidden"];
    if ([hideShadow boolValue]) {
        self.hbd_barShadowHidden = YES;
    }
    
    NSNumber *topBarHidden = self.options[@"topBarHidden"];
    if ([topBarHidden boolValue]) {
        self.hbd_barHidden = YES;
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
    
    NSDictionary *backItem = self.options[@"backItem"];
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
    
    NSNumber *hidden = self.options[@"backButtonHidden"];
    if ([hidden boolValue]) {
        if (@available(iOS 11, *)) {
             [self.navigationItem setHidesBackButton:YES];
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        }
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

@end
