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
        _barStyle = [UINavigationBar appearance].barStyle;
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
            self.barStyle = UIBarStyleDefault;
        } else {
            self.barStyle = UIBarStyleBlack;
        }
    }
    
    NSString *topBarColor = self.options[@"topBarColor"];
    if (topBarColor) {
        self.hbd_barTintColor = [HBDUtils colorWithHexString:topBarColor];
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
        self.hbd_backInteractive = [interactive boolValue];
    } else {
        self.hbd_backInteractive = YES;
    }
    
    HBDGarden *garden = [[HBDGarden alloc] init];
    
    NSDictionary *rightBarButtonItem = self.options[@"rightBarButtonItem"];
    [garden setRightBarButtonItem:rightBarButtonItem forController:self];
    
    NSDictionary *leftBarButtonItem = self.options[@"leftBarButtonItem"];
    [garden setLeftBarButtonItem:leftBarButtonItem forController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:self.barStyle];
}

@end
