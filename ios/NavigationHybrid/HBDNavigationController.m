//
//  HBDNavigationController.m
//  NavigationHybrid
//
//  Created by Listen on 2017/12/16.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDNavigationController.h"
#import "HBDViewController.h"
#import "UIViewController+HBD.h"
#import "HBDNavigationBar.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDGarden.h"

@interface HBDNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *shadowImage;
@property (nonatomic, strong) UIView *topBarBackgroundView;

@end

@implementation HBDNavigationController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil]) {
        if ([rootViewController isKindOfClass:[HBDViewController class]]) {
            HBDViewController *root = (HBDViewController *)rootViewController;
            NSDictionary *tabItem = root.options[@"tabItem"];
            [self configTabItemWithDict:tabItem];
        }
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
    
    self.shadowImage = [HBDUtils findShadowImageAt:self.navigationBar];
    self.topBarBackgroundView = ((HBDNavigationBar *)self.navigationBar).alphaView;
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count > 1) {
        return self.topViewController.backInteractive || !self.topViewController.backButtonHidden;
    }
    return NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        float toAlpha = viewController.topBarHidden ? 0 : viewController.topBarAlpha;
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self updateNavigationBarStyle:viewController.statusBarStyle];
            [self updateNavigationBarAlpha:toAlpha];
            [self hideTopBarShadowImageIfNeededWithAlpha:toAlpha forViewController:viewController];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            if ([from isKindOfClass:[HBDViewController class]]) {
                if (context.isCancelled) {
                    float fromAlpha  =  from.topBarHidden ? 0 : from.topBarAlpha;
                    [self updateNavigationBarStyle:from.statusBarStyle];
                    [self updateNavigationBarAlpha:fromAlpha];
                    [self hideTopBarShadowImageIfNeededWithAlpha:fromAlpha forViewController:from];
                } else {
                    float toAlpha = to.topBarHidden ? 0 : to.topBarAlpha;
                    [self updateNavigationBarStyle:to.statusBarStyle];
                    [self updateNavigationBarAlpha:toAlpha];
                    [self hideTopBarShadowImageIfNeededWithAlpha:toAlpha forViewController:to];
                }
            }
        }];
    }
}

- (void)updateNavigationBarAlpha:(float)alpha {
    self.topBarBackgroundView.alpha = alpha;
    self.shadowImage.alpha = alpha;
}

- (void)hideTopBarShadowImageIfNeededWithAlpha:(float)alpha forViewController:(UIViewController *)vc {
    self.shadowImage.hidden = alpha == 0 || vc.topBarShadowHidden;
}

- (void)updateNavigationBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self.navigationBar setBarStyle:statusBarStyle == UIStatusBarStyleDefault ? UIBarStyleDefault : UIBarStyleBlack];
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
