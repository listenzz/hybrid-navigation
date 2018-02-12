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

@end

@implementation HBDNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        if ([rootViewController isKindOfClass:[HBDViewController class]]) {
            HBDViewController *root = (HBDViewController *)rootViewController;
            NSDictionary *tabItem = root.options[@"tabItem"];
            [self configTabItemWithDict:tabItem];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)configTabItemWithDict:(NSDictionary *)tabItem {
    if (tabItem) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        tabBarItem.title = tabItem[@"title"];
        tabBarItem.image = [HBDUtils UIImage:tabItem[@"icon"]];
        self.tabBarItem = tabBarItem;
        self.hidesBottomBarWhenPushed = [tabItem[@"hideTabBarWhenPush"] boolValue];
    }
}

@end
