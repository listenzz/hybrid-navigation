#import "HBDNavigationController.h"

#import "HBDViewController.h"
#import "HBDFadeAnimation.h"
#import "GlobalStyle.h"

#import <React/RCTLog.h>
#import <React/RCTUtils.h>

@interface HBDNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <UINavigationControllerDelegate> proxyDelegate;
@property(nonatomic, weak, readonly) HBDNavigationController *nav;
@property(nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;
- (BOOL)shouldUseFadeAnimationFrom:(UIViewController *)from to:(UIViewController *)to;
- (BOOL)shouldHandleInteractiveTransitionWithNavigationController:(HBDNavigationController *)nav;

@end

@interface HBDNavigationController ()

@property(nonatomic, weak) UIViewController *poppingViewController;
@property(nonatomic, strong) HBDNavigationControllerDelegate *navigationDelegate;

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
    BOOL shouldHandleInteractiveTransition = [self shouldHandleInteractiveTransitionWithNavigationController:nav];

    if (![self.proxyDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        if (self.interactiveTransition || (!coordinator && shouldHandleInteractiveTransition)) {
            CGFloat process = [pan translationInView:nav.view].x / nav.view.bounds.size.width;
            process = MIN(1.0, (MAX(0.0, process)));
            if (pan.state == UIGestureRecognizerStateBegan) {
                self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
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
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.proxyDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return [GlobalStyle globalStyle].interfaceOrientation;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.proxyDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    UIInterfaceOrientationMask mask = [GlobalStyle globalStyle].interfaceOrientation;
    if (mask & UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight;
    }
    if (mask & UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.proxyDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }

    if ([animationController isKindOfClass:[HBDFadeAnimation class]]) {
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
    }

    BOOL shouldUseFadeAnimation = NO;

    if ([fromVC isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdFromVC = (HBDViewController *)fromVC;
        if (hbdFromVC.forceScreenLandscape) {
            shouldUseFadeAnimation = YES;
        }
    }

    if (!shouldUseFadeAnimation && [toVC isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdToVC = (HBDViewController *)toVC;
        if (hbdToVC.forceScreenLandscape) {
            shouldUseFadeAnimation = YES;
        }
    }

    if (shouldUseFadeAnimation) {
        return [HBDFadeAnimation new];
    }

    return nil;
}

- (BOOL)shouldUseFadeAnimationFrom:(UIViewController *)from to:(UIViewController *)to {
    if ([from isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdFromVC = (HBDViewController *)from;
        if (hbdFromVC.forceScreenLandscape) {
            return YES;
        }
    }

    if ([to isKindOfClass:[HBDViewController class]]) {
        HBDViewController *hbdToVC = (HBDViewController *)to;
        if (hbdToVC.forceScreenLandscape) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)shouldHandleInteractiveTransitionWithNavigationController:(HBDNavigationController *)nav {
    if (nav.viewControllers.count < 2) {
        return NO;
    }

    UIViewController *from = nav.topViewController;
    UIViewController *to = nav.viewControllers[nav.viewControllers.count - 2];
    return [self shouldUseFadeAnimationFrom:from to:to];
}

- (void)showViewController:(UIViewController *_Nonnull)viewController withCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self.nav updateNavigationBarForViewController:viewController];
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (context.isCancelled) {
            [self.nav updateNavigationBarForViewController:from];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
        }
    }];
}

@end

@implementation HBDNavigationController

- (void)dealloc {
    RCTLogInfo(@"[Navigation] %s", __FUNCTION__);
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:nil toolbarClass:nil]) {
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

    UINavigationBarAppearance *scrollEdgeAppearance = [[UINavigationBarAppearance alloc] init];
    [scrollEdgeAppearance configureWithTransparentBackground];
    scrollEdgeAppearance.shadowColor = UIColor.clearColor;
    scrollEdgeAppearance.backgroundColor = UIColor.clearColor;
    self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance;
    self.navigationBar.standardAppearance = [scrollEdgeAppearance copy];

    self.navigationDelegate = [[HBDNavigationControllerDelegate alloc] initWithNavigationController:self];
    self.navigationDelegate.proxyDelegate = self.delegate;
    self.delegate = self.navigationDelegate;
    [self setNavigationBarHidden:YES animated:NO];
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

    return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (self.childViewControllers.count > 1) {
        self.poppingViewController = self.topViewController;
    }

    return [super popToRootViewControllerAnimated:animated];
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self setNavigationBarHidden:YES animated:NO];
}

@end
