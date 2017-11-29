//
//  HBDViewController.m
//  Pods
//
//  Created by Listen on 2017/11/25.
//

#import "HBDViewController.h"
#import "HBDGarden.h"

@interface HBDViewController ()

@end

@implementation HBDViewController

- (instancetype)initWithNavigator:(HBDNavigator *)navigator props:(NSDictionary *)props options:(NSDictionary *)options; {
    if (self = [super init]) {
        _navigator = navigator;
        _sceneId = [[NSUUID UUID] UUIDString];
        
        if (props == nil) {
            props = @{};
        }
        
        if (options == nil) {
            options = @{};
        }
        _props = props;
        _options = options;
    }
    return self;
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    NSLog(@"requestCode:%d, resultCode:%d, data:%@", requestCode, resultCode, data);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HBDGarden *garden = [[HBDGarden alloc] init];
    NSDictionary *titleItem = self.options[@"titleItem"];
    [garden setTitleItem:titleItem forController:self];
    
    NSDictionary *rightBarButtonItem = self.options[@"rightBarButtonItem"];
    [garden setRightBarButtonItem:rightBarButtonItem forController:self];
    
    NSDictionary *leftBarButtonItem = self.options[@"leftBarButtonItem"];
    [garden setLeftBarButtonItem:leftBarButtonItem forController:self];
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
