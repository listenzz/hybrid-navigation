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
   
    self.view.backgroundColor = [HBDGarden globalStyle].screenBackgroundColor;

    HBDGarden *garden = [[HBDGarden alloc] init];
    
    if ([HBDGarden globalStyle].isBackTitleHidden) {
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

@end
