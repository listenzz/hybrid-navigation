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

@interface HBDViewController ()

@property (nonatomic, assign) float topBarAlpha;
@property (nonatomic, strong) UIColor *topBarColor;
@property (nonatomic, assign) BOOL topBarHidden;
@property (nonatomic, assign) BOOL topBarShadowHidden;
@property (nonatomic, assign) BOOL backButtonHidden;
@property (nonatomic, assign) BOOL backInteractive;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation HBDViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    if (self = [super init]) {
        _sceneId = [[NSUUID UUID] UUIDString];
        _moduleName = moduleName;
        _options = options;
        _props = props;
        _topBarAlpha = 1.0;
        _statusBarStyle = UIStatusBarStyleDefault;
        _backInteractive = YES;
    }
    return self;
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    NSLog(@"requestCode:%ld, resultCode:%ld, data:%@", (long)requestCode, (long)resultCode, data);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [HBDGarden globalStyle].screenBackgroundColor;
    
    NSString *topBarStyle = self.options[@"topBarStyle"];
    if (topBarStyle) {
        if ([topBarStyle isEqualToString:@"dark-content"]) {
            self.statusBarStyle = UIStatusBarStyleDefault;
        } else {
            self.statusBarStyle = UIStatusBarStyleLightContent;
        }
    }
    
    NSString *topBarColor = self.options[@"topBarColor"];
    if (topBarColor) {
        self.topBarColor = [HBDUtils colorWithHexString:topBarColor];
    } else {
        self.topBarColor = [HBDGarden globalStyle].topBarColor;
    }
    
    NSNumber *hideShadow = self.options[@"topBarShadowHidden"];
    if ([hideShadow boolValue]) {
        self.topBarShadowHidden = YES;
    }
    
    NSNumber *topBarAlpha = self.options[@"topBarAlpha"];
    if (topBarAlpha) {
        self.topBarAlpha = [topBarAlpha floatValue];
    }
    
    NSNumber *topBarHidden = self.options[@"topBarHidden"];
    if ([topBarHidden boolValue]) {
        self.topBarHidden = YES;
        if (@available(iOS 11, *)) {
            [self.navigationItem setHidesBackButton:YES];
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        }
    }
    
    if ([HBDGarden globalStyle].isBackTitleHidden) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
    
    NSDictionary *titleItem = self.options[@"titleItem"];
    if (titleItem) {
        if (self.topBarHidden) {
            return;
        }
        NSString *moduleName = titleItem[@"moduleName"];
        if (!moduleName) {
            self.navigationItem.title = titleItem[@"title"];
        }
    }
    
    NSNumber *hidden = self.options[@"backButtonHidden"];
    if ([hidden boolValue]) {
        self.backButtonHidden = YES;
        if (@available(iOS 11, *)) {
             [self.navigationItem setHidesBackButton:YES];
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        }
    }
    
    NSNumber *interactive = self.options[@"backInteractive"];
    if (interactive) {
        self.backInteractive = [interactive boolValue];
    } else {
        self.backInteractive = YES;
    }
    
    HBDGarden *garden = [[HBDGarden alloc] init];
    
    NSDictionary *rightBarButtonItem = self.options[@"rightBarButtonItem"];
    [garden setRightBarButtonItem:rightBarButtonItem forController:self];
    
    NSDictionary *leftBarButtonItem = self.options[@"leftBarButtonItem"];
    [garden setLeftBarButtonItem:leftBarButtonItem forController:self];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    UIViewController *previous = [self previousViewController];
    if (parent == nil && previous) {
        if (previous.topBarHidden) {
            previous.topBarColor = previous.view.backgroundColor;
        }
        [self.navigationController.navigationBar setBarTintColor:previous.topBarColor];
    }
    [super willMoveToParentViewController:parent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:self.topBarColor];
}

- (UIViewController *)previousViewController {
    if (self.navigationController.viewControllers.count > 1) {
        return self.navigationController.viewControllers[self.navigationController.viewControllers.count -2];
    }
    return nil;
}

@end
