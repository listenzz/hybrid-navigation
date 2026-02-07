#import "HBDNavigationController.h"

#import "HBDViewController.h"
#import "HBDNavigationBar.h"
#import "HBDUtils.h"
#import "HBDPushAnimation.h"
#import "HBDPopAnimation.h"
#import "HBDFadeAnimation.h"
#import "GlobalStyle.h"

#import <React/RCTLog.h>

#define hairlineWidth (1.f/[UIScreen mainScreen].scale)

@interface HBDNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <UINavigationControllerDelegate> proxyDelegate;
@property(nonatomic, weak, readonly) HBDNavigationController *nav;
@property(nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property(nonatomic, assign) UIEdgeInsets hbd_savedAdditionalSafeAreaInsetsForTo;
@property(nonatomic, assign) BOOL hbd_didCompensateSafeAreaForTo;
@property(nonatomic, assign) UIEdgeInsets hbd_savedAdditionalSafeAreaInsetsForFrom;
@property(nonatomic, assign) BOOL hbd_didCompensateSafeAreaForFrom;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;
- (void)hbd_compensateSafeAreaForViewController:(UIViewController *)vc expectedTopInset:(CGFloat)expectedTopInset isToVC:(BOOL)isToVC;
- (void)hbd_restoreCompensatedSafeAreaForFrom:(UIViewController *)from to:(UIViewController *)to viewController:(UIViewController *)viewController;

@end

@interface HBDNavigationController ()

@property(nonatomic, readonly) HBDNavigationBar *navigationBar;
@property(nonatomic, strong) UIView *fromFakeBar;
@property(nonatomic, strong) UIView *toFakeBar;
@property(nonatomic, strong) UIImageView *fromFakeShadow;
@property(nonatomic, strong) UIImageView *toFakeShadow;
@property(nonatomic, weak) UIViewController *poppingViewController;
@property(nonatomic, strong) HBDNavigationControllerDelegate *navigationDelegate;

- (void)updateNavigationBarStyleForViewController:(UIViewController *)vc;

- (void)updateNavigationBarTintColorForViewController:(UIViewController *)vc;

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;

- (void)updateNavigationBarBackgroundForViewController:(UIViewController *)vc;

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController *)to;

- (void)clearFake;

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

    if (nav.transitionCoordinator) {
        return NO;
    }

    if (nav.viewControllers.count > 1) {
        UIViewController *topVC = nav.topViewController;
        return topVC.hbd_swipeBackEnabled && topVC.hbd_backInteractive;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.nav.interactivePopGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan {
    HBDNavigationController *nav = self.nav;

    id <UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;

    if (![self.proxyDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        if (self.interactiveTransition || (!coordinator && [self shouldBetterTransitionWithViewController:nav.topViewController])) {
            CGFloat process = [pan translationInView:nav.view].x / nav.view.bounds.size.width;
            process = MIN(1.0, (MAX(0.0, process)));
            if (pan.state == UIGestureRecognizerStateBegan) {
                self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
                //触发pop转场动画
                [nav popViewControllerAnimated:YES];
            } else if (pan.state == UIGestureRecognizerStateChanged) {
                UIPercentDrivenInteractiveTransition *transition = self.interactiveTransition;
                [transition updateInteractiveTransition:process];
            } else if (pan.state == UIGestureRecognizerStateEnded
                    || pan.state == UIGestureRecognizerStateCancelled) {
                if (process > 0.33) {
                    [self.interactiveTransition finishInteractiveTransition];
                } else {
                    [self.interactiveTransition cancelInteractiveTransition];
                }
                self.interactiveTransition = nil;
            }
        } else {
            id <HBDNavigationTransitionProtocol> target = (id <HBDNavigationTransitionProtocol>) [nav superInteractivePopGestureRecognizer].delegate;
            if ([target respondsToSelector:@selector(handleNavigationTransition:)]) {
                [target handleNavigationTransition:pan];
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.proxyDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }

    HBDNavigationController *nav = self.nav;
    id <UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    if (coordinator) {
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
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.proxyDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }

    UIViewController *poppingVC = self.nav.poppingViewController;
    if (poppingVC && [poppingVC isKindOfClass:[HBDViewController class]]) {
        [viewController didReceiveResultCode:poppingVC.resultCode resultData:poppingVC.resultData requestCode:0];
    }

    self.nav.poppingViewController = nil;

    if (!animated) {
        [self.nav updateNavigationBarForViewController:viewController];
        [self.nav clearFake];
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.proxyDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.proxyDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.proxyDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }

    if ([animationController isKindOfClass:[HBDPopAnimation class]]) {
        return self.interactiveTransition;
    }

    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.proxyDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    } else {
        // 检查是否需要使用淡入淡出动画（横屏页面）
        // 只要 from 或 to 页面有一个是横屏，就采用 fade 动画
        BOOL shouldUseFadeAnimation = NO;

        // 检查 fromVC 是否是横屏
        if ([fromVC isKindOfClass:[HBDViewController class]]) {
            HBDViewController *hbdFromVC = (HBDViewController *)fromVC;
            if (hbdFromVC.forceScreenLandscape) {
                shouldUseFadeAnimation = YES;
            }
        }

        // 检查 toVC 是否是横屏
        if (!shouldUseFadeAnimation && [toVC isKindOfClass:[HBDViewController class]]) {
            HBDViewController *hbdToVC = (HBDViewController *)toVC;
            if (hbdToVC.forceScreenLandscape) {
                shouldUseFadeAnimation = YES;
            }
        }

        if (shouldUseFadeAnimation) {
            return [HBDFadeAnimation new];
        }

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
        HBDViewController *hbd = (HBDViewController *) vc;
        shouldBetter = [hbd.options[@"passThroughTouches"] boolValue];
    }
    return shouldBetter;
}

- (void)hbd_compensateSafeAreaForViewController:(UIViewController *)vc expectedTopInset:(CGFloat)expectedTopInset isToVC:(BOOL)isToVC {
    if (vc.isViewLoaded) {
        [vc.view layoutIfNeeded];
    }
    CGFloat systemTop = vc.isViewLoaded ? vc.view.safeAreaInsets.top : 0;
    CGFloat compensate = expectedTopInset > systemTop ? (expectedTopInset - systemTop) : 0;
    if (isToVC) {
        self.hbd_savedAdditionalSafeAreaInsetsForTo = vc.additionalSafeAreaInsets;
        self.hbd_didCompensateSafeAreaForTo = (compensate > 0);
    } else {
        self.hbd_savedAdditionalSafeAreaInsetsForFrom = vc.additionalSafeAreaInsets;
        self.hbd_didCompensateSafeAreaForFrom = (compensate > 0);
    }
    if (compensate > 0) {
        UIEdgeInsets o = vc.additionalSafeAreaInsets;
        vc.additionalSafeAreaInsets = UIEdgeInsetsMake(o.top + compensate, o.left, o.bottom, o.right);
    }
}

- (void)hbd_restoreCompensatedSafeAreaForFrom:(UIViewController *)from to:(UIViewController *)to viewController:(UIViewController *)viewController {
    if (self.hbd_didCompensateSafeAreaForTo && to == viewController) {
        viewController.additionalSafeAreaInsets = self.hbd_savedAdditionalSafeAreaInsetsForTo;
        self.hbd_didCompensateSafeAreaForTo = NO;
    }
    if (self.hbd_didCompensateSafeAreaForFrom) {
        from.additionalSafeAreaInsets = self.hbd_savedAdditionalSafeAreaInsetsForFrom;
        self.hbd_didCompensateSafeAreaForFrom = NO;
    }
}

- (void)showViewController:(UIViewController *_Nonnull)viewController withCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];

    if (@available(iOS 12.0, *)) {
        // Fix a system bug https://github.com/listenzz/HBDNavigationBar/issues/35
        [self resetButtonLabelInNavBar:self.nav.navigationBar];
    }

    if (self.nav.poppingViewController) {
        // Inspired by QMUI
        UILabel *backButtonLabel = self.nav.navigationBar.backButtonLabel;
        if (backButtonLabel) {
            backButtonLabel.hbd_specifiedTextColor = backButtonLabel.textColor;
        }

        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        } completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            backButtonLabel.hbd_specifiedTextColor = nil;
        }];
    }

    [self.nav updateNavigationBarStyleForViewController:viewController];

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = [self shouldShowFakeBarFrom:from to:to viewController:viewController];
        if (shouldFake) {
            [self.nav updateNavigationBarTintColorForViewController:viewController];
            [self.nav showFakeBarFrom:from to:to];

            // 转场涉及旋转时不应用 safe area 补偿，避免布局错乱
            BOOL noRotation = CGAffineTransformIsIdentity(context.targetTransform);
            if (noRotation) {
                CGFloat expectedTopInset = CGRectGetMaxY(self.nav.navigationBar.frame);
                [self hbd_compensateSafeAreaForViewController:to expectedTopInset:expectedTopInset isToVC:YES];
                [self hbd_compensateSafeAreaForViewController:from expectedTopInset:expectedTopInset isToVC:NO];
            }
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
            if (@available(iOS 13.0, *)) {
                if (to == viewController) {
                    self.nav.navigationBar.scrollEdgeAppearance.backgroundColor = viewController.hbd_barTintColor;
                    self.nav.navigationBar.standardAppearance.backgroundColor = viewController.hbd_barTintColor;
                }
            }
        }
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.nav.poppingViewController = nil;
        [self hbd_restoreCompensatedSafeAreaForFrom:from to:to viewController:viewController];

        // Restore navigation bar state first, before clearing appearance.
        if (context.isCancelled) {
            if (to == viewController) {
                [self.nav updateNavigationBarForViewController:from];
            }
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
            UIViewController *poppingVC = self.nav.poppingViewController;
            if (poppingVC && [poppingVC isKindOfClass:[HBDViewController class]]) {
                [viewController didReceiveResultCode:poppingVC.resultCode resultData:poppingVC.resultData requestCode:0];
            }
        }

        if (@available(iOS 13.0, *)) {
            self.nav.navigationBar.scrollEdgeAppearance.backgroundColor = UIColor.clearColor;
            self.nav.navigationBar.standardAppearance.backgroundColor = UIColor.clearColor;
        }

        if (to == viewController) {
            [self.nav clearFake];
        }
    }];
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

// Fake bar: hide real bar (alpha=0) and add fromFakeBar/toFakeBar on each VC's view for smooth bar color change.
- (BOOL)shouldShowFakeBarFrom:(UIViewController *)from to:(UIViewController *)to viewController:(UIViewController *_Nonnull)viewController {
    if (to != viewController) {
        return NO;
    }
    // toVC 的 bar 为 hidden 时直接隐藏 UINavigationBar，不使用 fake bar
    if (to.hbd_barHidden) {
        return NO;
    }
    if ([GlobalStyle globalStyle].alwaysSplitNavigationBarTransition && to == viewController) {
        return YES;
    }

    if (![from.hbd_barTintColor.description isEqual:to.hbd_barTintColor.description]) {
        return YES;
    }

    return from.hbd_barAlpha < 1.0 || to.hbd_barAlpha < 1.0;
}

@end

@implementation HBDNavigationController

@dynamic navigationBar;

- (void)dealloc {
    RCTLogInfo(@"[Navigation] %s", __FUNCTION__);
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil]) {
        if ([rootViewController isKindOfClass:[HBDViewController class]]) {
            HBDViewController *root = (HBDViewController *) rootViewController;
            self.tabBarItem = root.tabBarItem;
            root.tabBarItem = nil;
            NSDictionary *tabItem = root.options[@"tabItem"];
            if (tabItem && tabItem[@"hideTabBarWhenPush"]) {
                self.hidesBottomBarWhenPushed = [tabItem[@"hideTabBarWhenPush"] boolValue];
            } else {
                self.hidesBottomBarWhenPushed = YES;
            }
        }
        self.viewControllers = @[rootViewController];
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

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *scrollEdgeAppearance = [[UINavigationBarAppearance alloc] init];
        [scrollEdgeAppearance configureWithTransparentBackground];
        scrollEdgeAppearance.shadowColor = UIColor.clearColor;
        scrollEdgeAppearance.backgroundColor = UIColor.clearColor;
        [scrollEdgeAppearance setBackIndicatorImage:[UINavigationBar appearance].backIndicatorImage transitionMaskImage:[UINavigationBar appearance].backIndicatorTransitionMaskImage];
        self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance;
        self.navigationBar.standardAppearance = [scrollEdgeAppearance copy];
    }

    self.navigationDelegate = [[HBDNavigationControllerDelegate alloc] initWithNavigationController:self];
    self.navigationDelegate.proxyDelegate = self.delegate;
    self.delegate = self.navigationDelegate;
}

- (void)setDelegate:(id <UINavigationControllerDelegate>)delegate {
    if ([delegate isKindOfClass:[HBDNavigationControllerDelegate class]] || !self.navigationDelegate) {
        [super setDelegate:delegate];
    } else {
        self.navigationDelegate.proxyDelegate = delegate;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (!coordinator) {
        [self updateNavigationBarForViewController:self.topViewController];
    }
}

/// 修正非 iPhone X 机型在 iOS 13+ 上，随 hbd_statusBarHidden 切换时系统 safe area 不准确的问题。
/// 刘海屏由系统处理即可；非刘海屏状态栏高度 20pt，系统有时报 0 或 40，需用 additionalSafeAreaInsets 补偿。
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if ([HBDUtils isIphoneX]) {
        return;
    }

    if (@available(iOS 13.0, *)) {
        UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
        UIEdgeInsets additionalInsets = self.additionalSafeAreaInsets;

        BOOL statusBarHidden = RCTKeyWindow().windowScene.statusBarManager.statusBarHidden;

        // 状态栏隐藏时系统可能把 top 算成 0，补 20pt 避免内容贴顶
        if (statusBarHidden && safeAreaInsets.top == 0) {
            self.additionalSafeAreaInsets = UIEdgeInsetsMake(20, additionalInsets.left, additionalInsets.bottom, additionalInsets.right);
        }

        // 状态栏显示时系统有时把 top 算成 40（多算 20pt），减 20pt 使有效 top 为状态栏高度
        if (!statusBarHidden && safeAreaInsets.top == 40) {
            self.additionalSafeAreaInsets = UIEdgeInsetsMake(-20, additionalInsets.left, additionalInsets.bottom, additionalInsets.right);
        }
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item) {
        if (!self.topViewController.hbd_backInteractive) {
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    UIViewController *vc = [super popViewControllerAnimated:animated];
    // vc != self.topViewController
    [self fixClickBackIssue];
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    NSArray *array = [super popToViewController:viewController animated:animated];
    [self fixClickBackIssue];
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    NSArray *array = [super popToRootViewControllerAnimated:animated];
    [self fixClickBackIssue];
    return array;
}

- (void)fixClickBackIssue {
    if (@available(iOS 13.0, *)) {
        return;
    }

    // fix：ios 11，12，当前后两个页面的 barStyle 不一样时，点击返回按钮返回，前一个页面的标题颜色响应迟缓或不响应
    id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (!(coordinator && coordinator.interactive)) {
        self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
        self.navigationBar.titleTextAttributes = self.topViewController.hbd_titleTextAttributes;
    }
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    // 仅全局 topBarHidden 时直接隐藏 UINavigationBar
    if ([GlobalStyle globalStyle].topBarHidden) {
        [self setNavigationBarHidden:YES animated:NO];
        return;
    }
    [self updateNavigationBarStyleForViewController:vc];
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarBackgroundForViewController:vc];
    [self updateNavigationBarTintColorForViewController:vc];
}

- (void)updateNavigationBarStyleForViewController:(UIViewController *)vc {
    self.navigationBar.barStyle = vc.hbd_barStyle;
}

- (void)updateNavigationBarTintColorForViewController:(UIViewController *)vc {
    self.navigationBar.tintColor = vc.hbd_tintColor;
    self.navigationBar.titleTextAttributes = vc.hbd_titleTextAttributes;
    if (@available(iOS 13.0, *)) {
        self.navigationBar.scrollEdgeAppearance.titleTextAttributes = vc.hbd_titleTextAttributes;
        self.navigationBar.standardAppearance.titleTextAttributes = vc.hbd_titleTextAttributes;
    }
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.fakeBackgroundView.alpha = vc.hbd_barAlpha;
    self.navigationBar.fakeShadowView.alpha = vc.hbd_barShadowAlpha;
}

- (void)updateNavigationBarBackgroundForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_barTintColor;
}

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController *_Nonnull)to {
    [UIView setAnimationsEnabled:NO];
    self.navigationBar.fakeBackgroundView.alpha = 0;
    self.navigationBar.fakeShadowView.alpha = 0;
    [self showFakeBarFrom:from];
    [self showFakeBarTo:to];
    [UIView setAnimationsEnabled:YES];
}

- (void)showFakeBarFrom:(UIViewController *)from {
    self.fromFakeBar.backgroundColor = from.hbd_barTintColor;
    self.fromFakeBar.alpha = from.hbd_barAlpha;
    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeBar];
    self.fromFakeShadow.alpha = from.hbd_barShadowAlpha;
    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
    [from.view addSubview:self.fromFakeShadow];
}

- (void)showFakeBarTo:(UIViewController *_Nonnull)to {
    self.toFakeBar.backgroundColor = to.hbd_barTintColor;
    self.toFakeBar.alpha = to.hbd_barAlpha;
    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeBar];
    self.toFakeShadow.alpha = to.hbd_barShadowAlpha;
    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
    [to.view addSubview:self.toFakeShadow];
}

- (UIView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIView alloc] init];
    }
    return _fromFakeBar;
}

- (UIView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIView alloc] init];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.fakeShadowView.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.fakeShadowView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.fakeShadowView.image];
        _toFakeShadow.backgroundColor = self.navigationBar.fakeShadowView.backgroundColor;
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
    CGFloat height = self.navigationBar.frame.size.height + self.navigationBar.frame.origin.y;
    if (vc.view.frame.size.height == self.view.frame.size.height) {
        return CGRectMake(0, 0, self.navigationBar.frame.size.width, height);
    }else{
        return CGRectMake(0, -height, self.navigationBar.frame.size.width, height);
    }
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - hairlineWidth, frame.size.width, hairlineWidth);
}

@end
