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

- (void)start {
    if ([[HBDReactBridgeManager instance] isReactModuleInRegistry]) {
        [self performSelector:@selector(start) withObject:nil afterDelay:0.0];
    } else {
        if (self.indicator) {
            [self.indicator stopAnimating];
            self.indicator = nil;
        }
        
        NSDictionary *style = [HBDGarden globalStyle];
        if (style) {
            [self setStyle:style];
        }
        
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

- (void)setStyle:(NSDictionary *)style {
    
    // topBarStyle
    NSString *topBarStyle = style[@"topBarStyle"];
    BOOL isLightContentStyle = [topBarStyle isEqualToString:@"light-content"];
    
    if (topBarStyle) {
        if ([topBarStyle isEqualToString:@"light-content"]) {
            [self.navigationBar setBarStyle:UIBarStyleBlack];
        } else {
            [self.navigationBar setBarStyle:UIBarStyleDefault];
        }
    }
    
    // topBarBackgroundColor
    NSString *topBarBackgroundColor = style[@"topBarBackgroundColor"];
    if (!topBarBackgroundColor) {
        if (isLightContentStyle) {
            topBarBackgroundColor = @"#000000";
        } else {
            topBarBackgroundColor = @"#ffffff";
        }
    }
    UIColor *color = [HBDUtils colorWithHexString:topBarBackgroundColor];
    [self.navigationBar setBackgroundImage:[HBDUtils imageWithColor:color] forBarMetrics:UIBarMetricsDefault];
    
    // shadowImeage
    NSDictionary *shadowImeage = style[@"shadowImage"];
    if (shadowImeage && ![shadowImeage isEqual:NSNull.null]) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = shadowImeage[@"image"];
        NSString *color = shadowImeage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        [self.navigationBar setShadowImage:image];
    }
    
    // backIcon
    NSDictionary *icon = style[@"backIcon"];
    if (icon) {
        UIImage *backIcon = [HBDUtils UIImage:icon];
        [self.navigationBar setBackIndicatorImage:backIcon];
        [self.navigationBar setBackIndicatorTransitionMaskImage:backIcon];
    }
    
    // titleTextColor, titleTextSize
    NSString *titleTextColor = style[@"titleTextColor"];
    NSNumber *titleTextSize = style[@"titleTextSize"];
    NSString *topBarTintColor = style[@"topBarTintColor"];
    
    NSMutableDictionary *titleAttributes = [[NSMutableDictionary alloc] init];
    if (titleTextColor) {
        [titleAttributes setObject:[HBDUtils colorWithHexString:titleTextColor] forKey:NSForegroundColorAttributeName];
    } else {
        if (topBarTintColor) {
            [titleAttributes setObject:[HBDUtils colorWithHexString:topBarTintColor] forKey:NSForegroundColorAttributeName];
        } else {
            if (isLightContentStyle) {
                [titleAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            } else {
                [titleAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
            }
        }
    }
    
    if (titleTextSize) {
        [titleAttributes setObject:[UIFont systemFontOfSize:[titleTextSize floatValue]] forKey:NSFontAttributeName];
    } else {
        [titleAttributes setObject:[UIFont systemFontOfSize:17.0] forKey:NSFontAttributeName];
    }
    
    [self.navigationBar setTitleTextAttributes:titleAttributes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(start) withObject:nil afterDelay:0.0];
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
