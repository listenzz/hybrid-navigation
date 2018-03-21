//
//  OneNativeViewController.m
//  Navigation
//
//  Created by Listen on 2018/1/30.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "OneNativeViewController.h"
#import <NavigationHybrid/NavigationHybrid.h>

@interface OneNativeViewController ()

@property (nonatomic, copy) NSString *greeting;

@end

@implementation OneNativeViewController

- (instancetype)init {
    if (self = [super init]) {
        _greeting = @"Hello, Native";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.greeting ?: @"Native";
    
    if (self.greeting) {
        self.topBarColor = [UIColor redColor];
    }
}

- (IBAction)pushToRN:(UIButton *)sender {
    if (self.navigationController) {
        HBDViewController *vc = [[HBDReactBridgeManager sharedInstance] controllerWithModuleName:@"Navigation" props:nil options:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToNative:(UIButton *)sender {
    if (self.navigationController) {
        OneNativeViewController *vc = [[OneNativeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
