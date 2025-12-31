#import "HBDTabBarController.h"

#import "HBDReactViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDFadeAnimation.h"
#import "HBDNativeEvent.h"

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
    NSString *tabBarBackgroundColor = options[@"tabBarBackgroundColor"];
    if (tabBarBackgroundColor) {
		if (@available(iOS 26.0, *)) {
			// [tabBar setBackgroundColor: [HBDUtils colorWithHexString:tabBarBackgroundColor]];
		} else
        if (@available(iOS 15.0, *)) {
            [tabBar standardAppearance].backgroundImage = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarBackgroundColor]];
            [tabBar scrollEdgeAppearance].backgroundImage = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarBackgroundColor]];
        } else {
            [tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarBackgroundColor]]];
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
	
    NSString *tabBarItemSelectedColor = options[@"tabBarItemSelectedColor"];
    NSString *tabBarItemNormalColor = options[@"tabBarItemNormalColor"];
	
	if (tabBarItemSelectedColor) {
		if (!tabBarItemNormalColor) {
			tabBarItemNormalColor = @"#666666";
		}
		UITabBarItemAppearance *tabBarItem = [UITabBarItemAppearance new];
		tabBarItem.normal.titleTextAttributes = @{
			NSForegroundColorAttributeName: [HBDUtils colorWithHexString:tabBarItemNormalColor],
		};
		tabBarItem.normal.iconColor = [HBDUtils colorWithHexString:tabBarItemNormalColor];
		tabBarItem.selected.titleTextAttributes = @{
			NSForegroundColorAttributeName: [HBDUtils colorWithHexString:tabBarItemSelectedColor],
		};
		tabBarItem.selected.iconColor =  [HBDUtils colorWithHexString:tabBarItemSelectedColor];
		tabBar.standardAppearance.stackedLayoutAppearance = tabBarItem;
		tabBar.scrollEdgeAppearance.stackedLayoutAppearance = tabBarItem;
		[UITabBar appearance].standardAppearance.stackedLayoutAppearance = tabBarItem;
		[UITabBar appearance].scrollEdgeAppearance.stackedLayoutAppearance = tabBarItem;
	}
	
	for (UIViewController *tab in self.childViewControllers) {
		HBDViewController *hbdvc = [self tabViewController:tab];
		[hbdvc updateTabBarItem:hbdvc.options];
	}
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedViewController:self.viewControllers[selectedIndex]];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([[HBDReactBridgeManager get] hasRootLayout] && self.intercepted) {
        long from = self.selectedIndex;
        long to = [self.childViewControllers indexOfObject:viewController];
		[[HBDNativeEvent getInstance] emitOnSwitchTab:@{
			@"sceneId": self.sceneId,
			@"from": @(from),
			@"to": @(to),
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
