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

@end

@implementation OneNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Native";
}


- (IBAction)pushToRN:(UIButton *)sender {
    if (self.navigationController) {
        HBDViewController *vc = [[HBDReactBridgeManager instance] controllerWithModuleName:@"ReactNavigation" props:nil options:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
