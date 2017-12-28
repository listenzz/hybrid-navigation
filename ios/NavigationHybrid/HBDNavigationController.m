//
//  HBDNavigationController.m
//
//  Created by Listen on 2017/12/16.
//

#import "HBDNavigationController.h"
#import "HBDViewController.h"

@interface HBDNavigationController ()

@end

@implementation HBDNavigationController

- (instancetype)initWithRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    _navigator = [[HBDNavigator alloc] init];
    UIViewController *vc = [_navigator controllerWithModuleName:moduleName props:props options:options];
    if (self = [super initWithRootViewController:vc]) {
        _navigator.navigationController = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
