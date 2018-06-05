//
//  NativeModalViewController.m
//  Navigation
//
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "NativeModalViewController.h"
#import <HBDModalViewController.h>

@interface NativeModalViewController ()

@end

@implementation NativeModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeModal:(UIButton *)sender {
    [self.hbd_modalViewController hideWithAnimated:YES completion:^(BOOL finished) {
        
    }];
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
