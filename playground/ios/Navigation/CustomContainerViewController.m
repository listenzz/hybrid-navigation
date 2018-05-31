//
//  CustomContainerViewController.m
//  Navigation
//
//  Created by Listen on 2018/5/30.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "CustomContainerViewController.h"

@interface CustomContainerViewController ()

@end

@implementation CustomContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self addChildViewController:self.overlayViewController];
    self.overlayViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.overlayViewController.view];
    [self.overlayViewController didMoveToParentViewController:self];
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
