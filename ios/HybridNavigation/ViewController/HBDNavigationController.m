#import "HBDNavigationController.h"

#import "HBDViewController.h"
#import "HBDNavigationBar.h"
#import "HBDUtils.h"
#import "HBDPushAnimation.h"
#import "HBDPopAnimation.h"
#import "GlobalStyle.h"

#import <React/RCTLog.h>



UIColor *blendColor(UIColor *from, UIColor *to, CGFloat percent) {
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

    CGFloat newRed = fromRed + (toRed - fromRed) * fminf(1, (float) (percent * 4));
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * fminf(1, (float) (percent * 4));
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * fminf(1, (float) (percent * 4));
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * fminf(1, (float) (percent * 4));
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

void adjustLayout(UIViewController *vc) {
    if (vc.hbd_extendedLayoutDidSet) {
        return;
    }
    vc.hbd_extendedLayoutDidSet = YES;

    BOOL isTranslucent = vc.hbd_barHidden || vc.hbd_barAlpha < 1.0 || colorHasAlphaComponent(vc.hbd_barTintColor);
    if (isTranslucent || vc.extendedLayoutIncludesOpaqueBars) {
        vc.edgesForExtendedLayout |= UIRectEdgeTop;
    } else {
        vc.edgesForExtendedLayout &= ~UIRectEdgeTop;
    }

    if (vc.hbd_barHidden) {
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets insets = vc.additionalSafeAreaInsets;
            CGFloat height = vc.navigationController.navigationBar.bounds.size.height;
            vc.additionalSafeAreaInsets = UIEdgeInsetsMake(-height + insets.top, insets.left, insets.bottom, insets.right);
        }
    }
}

void printViewHierarchy(UIView *view, NSString *prefix) {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSLog(@"%@%@ %@", prefix, viewName, NSStringFromCGRect(view.frame));
    if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            printViewHierarchy(sub, [NSString stringWithFormat:@"--%@", prefix]);
        }
    }
}

@interface HBDNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <UINavigationControllerDelegate> proxyDelegate;
@property(nonatomic, weak, readonly) HBDNavigationController *nav;
@property(nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;

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
        return topVC.hbd_swipeBackEnabled && topVC.hbd_backInteractive;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer API_AVAILABLE(ios(7.0)) {
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

    adjustLayout(viewController);

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
    if (poppingVC) {
        if (poppingVC.didHideActionBlock) {
            poppingVC.didHideActionBlock();
            poppingVC.didHideActionBlock = nil;
        }

        if ([poppingVC isKindOfClass:[HBDViewController class]]) {
            [viewController didReceiveResultCode:poppingVC.resultCode resultData:poppingVC.resultData requestCode:0];
        }
    } else {
        if (viewController.didShowActionBlock) {
            viewController.didShowActionBlock();
            viewController.didShowActionBlock = nil;
        }
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
        if (operation == UINavigationControllerOperationPush) {
            if ([self shouldBetterTransitionWithViewController:toVC]) {
                adjustLayout(toVC);
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

        }                            completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            backButtonLabel.hbd_specifiedTextColor = nil;
        }];
    }

    [self.nav updateNavigationBarStyleForViewController:viewController];

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = [self shouldShowFakeBarFrom:from to:to viewController:viewController];
        if (shouldFake) {
            // title attributes, button tint color, barStyle
            [self.nav updateNavigationBarTintColorForViewController:viewController];
            // background alpha, background color, shadow image alpha
            [self.nav showFakeBarFrom:from to:to];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
            if (@available(iOS 13.0, *)) {
                if (to == viewController) {
                    self.nav.navigationBar.scrollEdgeAppearance.backgroundColor = viewController.hbd_barTintColor;
                    self.nav.navigationBar.standardAppearance.backgroundColor = viewController.hbd_barTintColor;
                }
            }
        }
    }                            completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.nav.poppingViewController = nil;
        if (@available(iOS 13.0, *)) {
            self.nav.navigationBar.scrollEdgeAppearance.backgroundColor = UIColor.clearColor;
            self.nav.navigationBar.standardAppearance.backgroundColor = UIColor.clearColor;
        }

        if (context.isCancelled) {
            if (to == viewController) {
                [self.nav updateNavigationBarForViewController:from];
            }
        } else {
            // `to` != `viewController` when present
            [self.nav updateNavigationBarForViewController:viewController];
            UIViewController *poppingVC = self.nav.poppingViewController;
            if (poppingVC) {
                if (poppingVC.didHideActionBlock) {
                    poppingVC.didHideActionBlock();
                    poppingVC.didHideActionBlock = nil;
                }

                if ([poppingVC isKindOfClass:[HBDViewController class]]) {
                    [viewController didReceiveResultCode:poppingVC.resultCode resultData:poppingVC.resultData requestCode:0];
                }
            } else {
                if (viewController.didShowActionBlock) {
                    viewController.didShowActionBlock();
                    viewController.didShowActionBlock = nil;
                }
            }
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

- (BOOL)shouldShowFakeBarFrom:(UIViewController *)from to:(UIViewController *)to viewController:(UIViewController *_Nonnull)viewController {
    if ([GlobalStyle globalStyle].alwaysSplitNavigationBarTransition && to == viewController) {
        return YES;
    }

    if (to != viewController) {
        return NO;
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
    RCTLogInfo(@"[Navigator] %s", __FUNCTION__);
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

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if ([HBDUtils isIphoneX]) {
        return;
    }

    if (@available(iOS 13.0, *)) {
        UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
        UIEdgeInsets additionalInsets = self.additionalSafeAreaInsets;

        // RCTLogInfo(@"[Navigator] safeAreaInsets:%@, additionalInsets:%@", NSStringFromUIEdgeInsets(safeAreaInsets), NSStringFromUIEdgeInsets(additionalInsets));

        BOOL statusBarHidden = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarHidden;

        if (statusBarHidden && safeAreaInsets.top == 0) {
            self.additionalSafeAreaInsets = UIEdgeInsetsMake(20, additionalInsets.left, additionalInsets.bottom, additionalInsets.right);
        }

        if (!statusBarHidden && safeAreaInsets.top == 40) {
            self.additionalSafeAreaInsets = UIEdgeInsetsMake(-20, additionalInsets.left, additionalInsets.bottom, additionalInsets.right);
        }
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
    UIViewController *rootViewController = self.childViewControllers[0];
    if (self.topViewController.didHideActionBlock && self.topViewController == rootViewController) {
        self.topViewController.didHideActionBlock();
        self.topViewController.didHideActionBlock = nil;
    }

    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    UIViewController *vc = [super popViewControllerAnimated:animated];
    // vc != self.topViewController
    [self fixClickBackIssue];
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.topViewController.didHideActionBlock && self.topViewController == viewController) {
        self.topViewController.didHideActionBlock();
        self.topViewController.didHideActionBlock = nil;
    }

    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    NSArray *array = [super popToViewController:viewController animated:animated];
    [self fixClickBackIssue];
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    UIViewController *rootViewController = self.childViewControllers[0];
    if (self.topViewController.didHideActionBlock && self.topViewController == rootViewController) {
        self.topViewController.didHideActionBlock();
        self.topViewController.didHideActionBlock = nil;
    }

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

    if (@available(iOS 11.0, *)) {
        // fix：ios 11，12，当前后两个页面的 barStyle 不一样时，点击返回按钮返回，前一个页面的标题颜色响应迟缓或不响应
        id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
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
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull subview, NSUInteger idx, BOOL *_Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
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
    UIView *back = [self.navigationBar.subviews firstObject];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = 0;
    if ((vc.edgesForExtendedLayout & UIRectEdgeTop) == 0) {
        frame.origin.y = -frame.size.height;
    }

    // fix issue for pushed to UIViewController whose root view is UIScrollView.
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *) vc.view;
        scrollView.clipsToBounds = NO;
        if (scrollView.contentOffset.y == 0) {
            frame.origin.y = -frame.size.height;
        }
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y, frame.size.width, 0.5);
}

@end
