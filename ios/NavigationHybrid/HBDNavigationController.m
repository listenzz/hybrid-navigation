//
//  HBDNavigationController.m
//
//  Created by Listen on 2017/12/16.
//

#import "HBDNavigationController.h"
#import "HBDViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDGarden.h"

@interface HBDNavigationController ()

@property (nonatomic, copy) NSString *initialModuleName;
@property (nonatomic, copy) NSDictionary *initialProps;
@property (nonatomic, copy) NSDictionary *initialOptions;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation HBDNavigationController

- (instancetype)initWithRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    _initialModuleName = moduleName;
    _initialProps = props;
    _initialOptions = options;
    
    UIViewController *vc = [[UIViewController alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view setBackgroundColor:UIColor.whiteColor];
    UIActivityIndicatorView *indicator =  [[UIActivityIndicatorView alloc] init];
    indicator.color = UIColor.grayColor;
    _indicator = indicator;
    [indicator startAnimating];
    [view addSubview:indicator];
    indicator.center = view.center;
    vc.view = view;
    vc.title = @"loading...";
    
    if (self = [super initWithRootViewController:vc]) {
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(start) withObject:nil afterDelay:0.0];
}

- (void)start {
    if ([[HBDReactBridgeManager instance] isReactModuleInRegistry]) {
        [self performSelector:@selector(start) withObject:nil afterDelay:0.0];
    } else {
        if (self.indicator) {
            [self.indicator stopAnimating];
            self.indicator = nil;
        }
        
        [[HBDGarden globalStyle] inflateNavigationBar:self.navigationBar];
        
        [self setViewControllers:@[[[HBDReactBridgeManager instance] controllerWithModuleName:_initialModuleName props:_initialProps options:_initialOptions]] animated:NO];
        
        [self configTabItem];
    }
}

- (void)configTabItem {
    NSDictionary *options = [[HBDReactBridgeManager instance] reactModuleOptionsForKey:_initialModuleName];
    NSDictionary *tabItem = options[@"tabItem"];
    if (tabItem) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        tabBarItem.title = tabItem[@"title"];
        tabBarItem.image = [HBDUtils UIImage:tabItem[@"icon"]];
        self.tabBarItem = tabBarItem;
        self.hidesBottomBarWhenPushed = [tabItem[@"hideTabBarWhenPush"] boolValue];
    }
}

@end
