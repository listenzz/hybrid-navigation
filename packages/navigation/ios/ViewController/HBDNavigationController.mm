#import "HBDNavigationController.h"

#import "HBDViewController.h"

#import <React/RCTLog.h>
#import <React/RCTUtils.h>

@interface HBDNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <UINavigationControllerDelegate> proxyDelegate;
@property(nonatomic, weak, readonly) HBDNavigationController *nav;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;

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
        if ([topVC isKindOfClass:[HBDViewController class]] && ((HBDViewController *)topVC).forceScreenLandscape) {
            return NO;
        }
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

    if (![self.proxyDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        id <HBDNavigationTransitionProtocol> target = (id <HBDNavigationTransitionProtocol>) [nav superInteractivePopGestureRecognizer].delegate;
        if ([target respondsToSelector:@selector(handleNavigationTransition:)]) {
            [target handleNavigationTransition:pan];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.proxyDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
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
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if (self.proxyDelegate && [self.proxyDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.proxyDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
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

    return nil;
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

@end
