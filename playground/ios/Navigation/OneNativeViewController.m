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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.props[@"greeting"] ?: @"Native";
    
    if (self.props[@"greeting"]) {
        self.hbd_barTintColor = [UIColor redColor];
    }
}

- (IBAction)pushToRN:(UIButton *)sender {
    if (self.navigationController) {
        NSDictionary *passedProps = nil;
        if(self.props[@"popToId"]) {
            passedProps = @{@"popToId": self.props[@"popToId"]};
        }
        else {
            passedProps = @{@"popToId": self.sceneId};
        }
        HBDViewController *vc = [[HBDReactBridgeManager get] controllerWithModuleName:@"Navigation" props:passedProps options:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToNative:(UIButton *)sender {
    if (self.navigationController) {
        NSDictionary *passedProps = nil;
        if(self.props[@"popToId"]) {
            passedProps = @{@"popToId": self.props[@"popToId"], @"greeting": @"Hello, Native"};
        }
        else {
            passedProps = @{@"popToId": self.sceneId, @"greeting": @"Hello, Native"};
        }
        OneNativeViewController *vc = [[OneNativeViewController alloc] initWithModuleName:nil props:passedProps options:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
