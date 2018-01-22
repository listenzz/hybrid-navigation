//
//  HBDViewController.m
//
//  Created by Listen on 2017/11/25.
//

#import "HBDViewController.h"
#import "HBDGarden.h"
#import "HBDUtils.h"
#import "HBDNavigationController.h"


@interface HBDViewController ()

@property (nonatomic, strong) UIImageView *shadowImage;

@end

@implementation HBDViewController

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    if (self = [super init]) {
        _sceneId = [[NSUUID UUID] UUIDString];
        _moduleName = moduleName;
        _options = options;
        _props = props;
    }
    return self;
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    NSLog(@"requestCode:%ld, resultCode:%ld, data:%@", (long)requestCode, (long)resultCode, data);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [HBDGarden screenBackgroundColor];

    HBDGarden *garden = [[HBDGarden alloc] init];
    
    if ([HBDGarden isBackTitleHidden]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
    
    NSDictionary *titleItem = self.options[@"titleItem"];
    [garden setTitleItem:titleItem forController:self];
    
    NSNumber *hidden = self.options[@"hideBackButton"];
    if ([hidden boolValue]) {
        [garden setHideBackButton:[hidden boolValue] forController:self];
    }
    
    NSNumber *hideShadow = self.options[@"hideShadow"];
    if ([hideShadow boolValue]) {
        self.shadowImage = [HBDUtils findShadowImageAt:self.navigationController.navigationBar];
    }
    
    NSDictionary *rightBarButtonItem = self.options[@"rightBarButtonItem"];
    [garden setRightBarButtonItem:rightBarButtonItem forController:self];
    
    NSDictionary *leftBarButtonItem = self.options[@"leftBarButtonItem"];
    [garden setLeftBarButtonItem:leftBarButtonItem forController:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.shadowImage) {
        self.shadowImage.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.shadowImage) {
        self.shadowImage.hidden = NO;
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
