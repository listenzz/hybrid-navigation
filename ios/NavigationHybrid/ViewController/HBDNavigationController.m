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
#import "HBDReactViewController.h"
#import "HBDRootView.h"
#import "HBDPushAnimation.h"
#import "HBDPopAnimation.h"

UIColor* blendColor(UIColor *from, UIColor *to, float percent) {
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed =  fromRed + (toRed - fromRed) * fminf(1, percent * 4) ;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * fminf(1, percent * 4);
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * fminf(1, percent * 4);
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * fminf(1, percent * 4);
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@interface HBDNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> proxiedDelegate;
@property (nonatomic, weak, readonly) HBDNavigationController *nav;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;

@end

@interface HBDNavigationController ()

@property (nonatomic, readonly) HBDNavigationBar *navigationBar;
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, weak) UIViewController *poppingViewController;
@property (nonatomic, assign) BOOL transitional;
@property (nonatomic, strong) HBDNavigationControllerDelegate *navigationDelegate;

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarColorForViewController:(UIViewController *)vc;
- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc;

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController * _Nonnull)to;

- (void)clearFake;

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar;

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer;

@end

@protocol HBDNavigationTransitionProtocol <NSObject>

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan;

@end

@implementation HBDNavigationControllerDelegate

- (instancetype)initWithNavigationController:(HBDNavigationController *)nav {
    if (self = [super init]) {
        _nav = nav;
        self.edges = UIRectEdgeLeft;
        self.delegate = self;
        [self addTarget:self action:@selector(handleNavigationTransition:)];
        [nav.view addGestureRecognizer:self];
        [nav superInteractivePopGestureRecognizer].enabled = NO;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    HBDNavigationController *nav = self.nav;
    if (nav.viewControllers.count > 1) {
        UIViewController *topVC = nav.topViewController;
        if ([topVC isKindOfClass:[HBDReactViewController class]]) {
            HBDReactViewController *vc = (HBDReactViewController *)topVC;
            [vc.rootView cancelTouches];
        }
        return topVC.hbd_backInteractive && topVC.hbd_swipeBackEnabled;
    }
    return NO;
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan {
    HBDNavigationController *nav = self.nav;
    
    id<UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    
    if (![self.proxiedDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        if (self.interactiveTransition || (!coordinator && [self shouldBetterTransitionWithViewController:nav.topViewController])) {
            CGFloat process = [pan translationInView:nav.view].x / nav.view.bounds.size.width;
            process = MIN(1.0,(MAX(0.0, process)));
            if (pan.state == UIGestureRecognizerStateBegan) {
                self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
                //触发pop转场动画
                [nav popViewControllerAnimated:YES];
            }else if (pan.state == UIGestureRecognizerStateChanged){
                UIPercentDrivenInteractiveTransition *transition = self.interactiveTransition;
                [transition updateInteractiveTransition:process];
            }else if (pan.state == UIGestureRecognizerStateEnded
                      || pan.state == UIGestureRecognizerStateCancelled){
                if (process > 0.33) {
                    [ self.interactiveTransition finishInteractiveTransition];
                }else{
                    [ self.interactiveTransition cancelInteractiveTransition];
                }
                self.interactiveTransition = nil;
            }
        } else {
            id<HBDNavigationTransitionProtocol> target = (id<HBDNavigationTransitionProtocol>)[nav superInteractivePopGestureRecognizer].delegate;
            if ([target respondsToSelector:@selector(handleNavigationTransition:)]) {
                [target handleNavigationTransition:pan];
            }
        }
    }
    
    // ----
    if (coordinator) {
        if (@available(iOS 11.0, *)) {
            // empty
        } else {
            UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
                nav.navigationBar.tintColor = blendColor(from.hbd_tintColor, to.hbd_tintColor, coordinator.percentComplete);
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.proxiedDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    
    HBDNavigationController *nav = self.nav;
    nav.transitional = YES;

    id<UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    if (coordinator) {
        if (@available(iOS 13.0, *)) {
            // empty
        } else if (@available(iOS 11.0, *)) {
            if (coordinator.interactive) {
               // fix：ios 11，12 当前后两个页面的 barStyle 不一样时，侧滑返回，导航栏左右两眉样式过渡不一致的问题
                nav.navigationBar.barStyle = viewController.hbd_barStyle;
                nav.navigationBar.titleTextAttributes = viewController.hbd_titleTextAttributes;
            }
        }
        [self showViewController:viewController withCoordinator:coordinator];
    } else {
        if (!animated && nav.childViewControllers.count > 1) {
            UIViewController *lastButOne = nav.childViewControllers[nav.childViewControllers.count - 2];
            if ([self shouldShowFakeBarFrom:lastButOne to:viewController viewController:viewController]) {
                [nav showFakeBarFrom:lastButOne to:viewController];
                return;
            }
        }
        [nav updateNavigationBarForViewController:viewController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.proxiedDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
    
    HBDNavigationController *nav = self.nav;
    nav.transitional = NO;
    if (!animated) {
       [nav updateNavigationBarForViewController:viewController];
       [nav clearFake];
    }
    
    UIViewController *poppingVC = nav.poppingViewController;
    if (poppingVC && [poppingVC isKindOfClass:[HBDViewController class]]) {
        [viewController didReceiveResultCode:poppingVC.resultCode resultData:poppingVC.resultData requestCode:0];
    }
    
    if (@available(iOS 11.0, *)) {
        viewController.navigationItem.backBarButtonItem = viewController.hbd_backBarButtonItem;
    }

    nav.poppingViewController = nil;
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.proxiedDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController  {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.proxiedDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController  {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.proxiedDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }

    if ([animationController isKindOfClass:[HBDPopAnimation class]]) {
       return self.interactiveTransition;
    }

    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  {
    if (self.proxiedDelegate && [self.proxiedDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.proxiedDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    } else {
        if (operation == UINavigationControllerOperationPush) {
            if ([self shouldBetterTransitionWithViewController:toVC]) {
                return [HBDPushAnimation new];
            }
        } else if (operation == UINavigationControllerOperationPop) {
            if ([self shouldBetterTransitionWithViewController:fromVC]) {
                return [HBDPopAnimation new];
            }
        }
    }

    return nil;
}

- (BOOL)shouldBetterTransitionWithViewController:(UIViewController *)vc {
    BOOL shouldBetter = NO;
    if ([vc isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbd = (HBDViewController *)vc;
        shouldBetter = [hbd.options[@"passThroughTouches"] boolValue];
    }
    return shouldBetter;
}

- (void)showViewController:(UIViewController * _Nonnull)viewController withCoordinator: (id<UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (@available(iOS 12.0, *)) {
        // Fix a system bug https://github.com/listenzz/HBDNavigationBar/issues/35
        [self resetButtonLabelInNavBar:self.nav.navigationBar];
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = [self shouldShowFakeBarFrom:from to:to viewController:viewController];
        if (shouldFake) {
            // title attributes, button tint colo, barStyle
            [self.nav updateNavigationBarAnimatedForViewController:viewController];
            // background alpha, background color, shadow image alpha
            [self.nav showFakeBarFrom:from to:to];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.nav.transitional = NO;
        self.nav.poppingViewController = nil;
        if (context.isCancelled) {
            [self.nav updateNavigationBarForViewController:from];
        } else {
            // `to` != `viewController` when present
            [self.nav updateNavigationBarForViewController:viewController];
        }
        if (to == viewController) {
            [self.nav clearFake];
        }
    }];
    
    if (coordinator.interactive) {
        if (@available(iOS 10.0, *)) {
            [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                
                if (context.isCancelled) {
                    [self.nav updateNavigationBarAnimatedForViewController:from];
                } else {
                    [self.nav updateNavigationBarAnimatedForViewController:viewController];
                }
            }];
        } else {
            [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (context.isCancelled) {
                    [self.nav updateNavigationBarAnimatedForViewController:from];
                } else {
                    [self.nav updateNavigationBarAnimatedForViewController:viewController];
                }
            }];
        }
    }
}

- (void)resetButtonLabelInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 12.0, *)) {
        for (UIView *view in navBar.subviews) {
            NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            if ([viewName isEqualToString:@"UINavigationBarContentView"]) {
                [self resetButtonLabelInView:view];
                break;
            }
        }
    }
}

- (void)resetButtonLabelInView:(UIView *)view {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    if ([viewName isEqualToString:@"UIButtonLabel"]) {
        view.alpha = 1.0;
    } else if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            [self resetButtonLabelInView:sub];
        }
    }
}

- (BOOL)shouldShowFakeBarFrom:(UIViewController *)from to:(UIViewController *)to viewController:(UIViewController * _Nonnull)viewController {
    BOOL shouldFake = to == viewController && (![from.hbd_barTintColor.description  isEqual:to.hbd_barTintColor.description] || ABS(from.hbd_barAlpha - to.hbd_barAlpha) > 0.1);
    return shouldFake;
}

@end

@implementation HBDNavigationController

@dynamic navigationBar;

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil]) {
        if ([rootViewController isKindOfClass:[HBDViewController class]]) {
            HBDViewController *root = (HBDViewController *)rootViewController;
            self.tabBarItem = root.tabBarItem;
            root.tabBarItem = nil;
            NSDictionary *tabItem = root.options[@"tabItem"];
            if (tabItem) {
                self.hidesBottomBarWhenPushed = [tabItem[@"hideTabBarWhenPush"] boolValue];
            }
        }
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (UIGestureRecognizer *)interactivePopGestureRecognizer {
    return self.navigationDelegate;
}

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer {
    return [super interactivePopGestureRecognizer];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
    
    self.navigationDelegate = [[HBDNavigationControllerDelegate alloc] initWithNavigationController:self];
    self.navigationDelegate.proxiedDelegate = self.delegate;
    self.delegate = self.navigationDelegate;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if ([delegate isKindOfClass:[HBDNavigationControllerDelegate class]] || !self.navigationDelegate) {
        [super setDelegate:delegate];
    } else {
        self.navigationDelegate.proxiedDelegate = delegate;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // 修复一个神奇的 BUG https://github.com/listenzz/HBDNavigationBar/issues/29
    UIViewController *top = self.topViewController;
    top.view.frame = top.view.frame;

    if (@available(iOS 11.0, *)) {
        if (top.navigationItem.backBarButtonItem && !self.poppingViewController) {
            top.hbd_backBarButtonItem = top.navigationItem.backBarButtonItem;
        }
    }
    
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        if (@available(iOS 11.0, *)) {
            UIViewController *fromVC = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            
            if (fromVC == self.poppingViewController && toVC.navigationController == self) {
                UIBarButtonItem *oldButtonItem = toVC.navigationItem.backBarButtonItem;
                UIBarButtonItem *newButtonItem = [[UIBarButtonItem alloc] init];
                if (oldButtonItem) {
                    newButtonItem.title = oldButtonItem.title;
                } else {
                    newButtonItem.title = self.navigationBar.backButtonLabel.text;
                }
                newButtonItem.tintColor = fromVC.hbd_tintColor;
                toVC.navigationItem.backBarButtonItem = newButtonItem;
            }
            
            if (toVC == top && fromVC.navigationController == self) {
                UIBarButtonItem *backItem = fromVC.navigationItem.backBarButtonItem;
                if (backItem) {
                    backItem.tintColor = toVC.hbd_tintColor;
                }
            }
            
            // 解决 ios 11 手势反弹的问题
            if (fromVC == self.poppingViewController && !self.transitional) {
                [self updateNavigationBarForViewController:fromVC];
            }
        }
    } else {
        // 再修复一个神奇的 BUG: https://github.com/listenzz/HBDNavigationBar/issues/31
        [self updateNavigationBarForViewController:self.topViewController];
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item) {
        if (!self.topViewController.hbd_backInteractive) {
            [self resetSubviewsInNavBar:self.navigationBar];
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    UIViewController *vc = [super popViewControllerAnimated:animated];
    // vc != self.topViewController
    [self fixClickBackIssue];
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToViewController:viewController animated:animated];
    [self fixClickBackIssue];
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    [self fixClickBackIssue];
    return array;
}

- (void)fixClickBackIssue {
    if (@available(iOS 13.0, *)) {
        // empty
    } else if (@available(iOS 11.0, *)){
        // fix：ios 11，12，当前后两个页面的 barStyle 不一样时，点击返回按钮返回，前一个页面的标题颜色响应迟缓或不响应
        id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
        if (!(coordinator && coordinator.interactive)) {
            self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
            self.navigationBar.titleTextAttributes = self.topViewController.hbd_titleTextAttributes;
        }
    }
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
        // empty
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)printSubViews:(UIView *)view prefix:(NSString *)prefix {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSLog(@"%@%@", prefix, viewName);
    if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            [self printSubViews:sub prefix:[NSString stringWithFormat:@"--%@", prefix]];
        }
    }
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorForViewController:vc];
    [self updateNavigationBarShadowImageAlphaForViewController:vc];
    [self updateNavigationBarAnimatedForViewController:vc];
}

- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc {
    self.navigationBar.tintColor = vc.hbd_tintColor;
    self.navigationBar.barStyle = vc.hbd_barStyle;
    self.navigationBar.titleTextAttributes = vc.hbd_titleTextAttributes;
    
    if (@available(iOS 11.0, *)) {
        if (!self.poppingViewController) {
            __block NSInteger index = -1;
            if (!self.transitional) {
                [self.childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj == vc) {
                        index = idx - 1;
                        *stop = YES;
                    }
                }];
            }
            
            if (index > -1) {
                UIViewController *backItemVC = self.childViewControllers[index];
                UIBarButtonItem *backItem = backItemVC.navigationItem.backBarButtonItem;
                if (backItem) {
                    backItem = [[UIBarButtonItem alloc] init];
                    UIBarButtonItem *storedBackItem = backItemVC.hbd_backBarButtonItem;
                    if (storedBackItem) {
                        backItem.title = storedBackItem.title;
                    } else {
                        backItem.title = self.navigationBar.backButtonLabel.text;
                    }
                    backItem.tintColor = vc.hbd_tintColor;
                    backItemVC.navigationItem.backBarButtonItem = backItem;
                }
            }
        }
    }
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.fakeView.alpha = vc.hbd_barAlpha;
    self.navigationBar.shadowImageView.alpha = vc.hbd_barShadowAlpha;
}

- (void)updateNavigationBarColorForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_barTintColor;
}

- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.hbd_barShadowAlpha;
}

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController * _Nonnull)to {
    [UIView setAnimationsEnabled:NO];
    self.navigationBar.fakeView.alpha = 0;
    self.navigationBar.shadowImageView.alpha = 0;
    [self showFakeBarFrom:from];
    [self showFakeBarTo:to];
    [UIView setAnimationsEnabled:YES];
}

- (void)showFakeBarFrom:(UIViewController *)from {
    self.fromFakeBar.subviews.lastObject.backgroundColor = from.hbd_barTintColor;
    self.fromFakeBar.alpha = from.hbd_barAlpha == 0 ? 0.01 : from.hbd_barAlpha;
    if (from.hbd_barAlpha == 0) {
        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
    }
    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeBar];
    self.fromFakeShadow.alpha = from.hbd_barShadowAlpha;
    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
    [from.view addSubview:self.fromFakeShadow];
}

- (void)showFakeBarTo:(UIViewController * _Nonnull)to {
    self.toFakeBar.subviews.lastObject.backgroundColor = to.hbd_barTintColor;
    self.toFakeBar.alpha = to.hbd_barAlpha;
    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeBar];
    self.toFakeShadow.alpha = to.hbd_barShadowAlpha;
    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
    [to.view addSubview:self.toFakeShadow];
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _toFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)clearFake {
    [self.fromFakeBar removeFromSuperview];
    [self.toFakeBar removeFromSuperview];
    [self.fromFakeShadow removeFromSuperview];
    [self.toFakeShadow removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = 0;
    //  解决根视图为scrollView的时候，Push不正常
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollview = (UIScrollView *)vc.view;
        //  适配iPhoneX iPhoneXR
        NSArray *xrs =@[ @812, @896 ];
        BOOL isIPhoneX = [xrs containsObject:@([UIScreen mainScreen].bounds.size.height)];
        if (scrollview.contentOffset.y == 0) {
            frame.origin.y = -(isIPhoneX ? 88 : 64);
        }
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y, frame.size.width, 0.5);
}

@end
