#import "HBDTabBarController.h"

#import "HBDReactViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDEventEmitter.h"
#import "HBDReactTabBar.h"
#import "HBDFadeAnimation.h"

#import <React/RCTRootView.h>
#import <React/RCTRootViewDelegate.h>
#import <React/RCTLog.h>


@interface HBDTabBarController () <UITabBarControllerDelegate>

@end

@implementation HBDTabBarController

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    self.delegate = self;
    self.intercepted = YES;
}

- (void)setTabItem:(NSArray<NSDictionary *> *)options {
    for (NSDictionary *option in options) {
        NSUInteger index = (NSUInteger) (option[@"index"] ? [option[@"index"] integerValue] : 0);
		UIViewController *tab = self.viewControllers[index];
		HBDViewController *hbdvc = [self tabViewController:tab];
		[hbdvc updateTabBarItem:option];
    }
}


- (HBDViewController *)tabViewController:(UIViewController *)vc {
	if ([vc isKindOfClass:[UINavigationController class]]) {
		UINavigationController *nav = (UINavigationController *)vc;
		return [self tabViewController:[nav.viewControllers firstObject]];
	} else if ([vc isKindOfClass:[HBDViewController class]]) {
		return (HBDViewController *)vc;
	}
	
	return nil;
}

- (void)updateTabBar:(NSDictionary *)options {
    UITabBar *tabBar = self.tabBar;
    NSString *tabBarColor = options[@"tabBarColor"];
    if (tabBarColor) {
        if (@available(iOS 15.0, *)) {
            [tabBar standardAppearance].backgroundImage = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]];
            [tabBar scrollEdgeAppearance].backgroundImage = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]];
        } else {
            [tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]]];
        }
    }

    NSDictionary *tabBarShadowImage = options[@"tabBarShadowImage"];
    if (RCTNilIfNull(tabBarShadowImage)) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = tabBarShadowImage[@"image"];
        NSString *color = tabBarShadowImage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        tabBar.shadowImage = image;
    }

    NSString *tabBarItemColor = options[@"tabBarItemColor"];
    NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
    if (tabBarItemColor) {
		tabBar.tintColor = [HBDUtils colorWithHexString:tabBarItemColor];
		[UITabBar appearance].tintColor = tabBar.tintColor;
		if (tabBarUnselectedItemColor) {
			tabBar.unselectedItemTintColor = [HBDUtils colorWithHexString:tabBarUnselectedItemColor];
			[UITabBar appearance].unselectedItemTintColor = tabBar.unselectedItemTintColor;
		}
    }
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedViewController:self.viewControllers[selectedIndex]];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    [super setSelectedViewController:selectedViewController];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([[HBDReactBridgeManager get] hasRootLayout] && self.intercepted) {
        long from = self.selectedIndex;
        long to = [self.childViewControllers indexOfObject:viewController];

        [HBDEventEmitter sendEvent:EVENT_SWITCH_TAB data:@{
                KEY_SCENE_ID: self.sceneId,
                KEY_INDEX: [NSString stringWithFormat:@"%ld-%ld", from, to],
        }];
        return NO;
    }
    return YES;
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
	
    if (toVC.viewLoaded) {
        return nil;
    }
    
    return [[HBDFadeAnimation alloc] init];
}

@end
