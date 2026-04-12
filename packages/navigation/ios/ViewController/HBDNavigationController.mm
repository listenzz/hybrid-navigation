#import "HBDNavigationController.h"

#import "HBDViewController.h"

#import <React/RCTLog.h>
#import <React/RCTUtils.h>

@interface HBDNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) UIViewController *poppingViewController;
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *navigationPopGestureRecognizer;

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer;
- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan;

@end

@protocol HBDNavigationTransitionProtocol <NSObject>

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan;

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
    return self.navigationPopGestureRecognizer;
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

    self.navigationPopGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationTransition:)];
    self.navigationPopGestureRecognizer.edges = UIRectEdgeLeft;
    self.navigationPopGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.navigationPopGestureRecognizer];
    [self superInteractivePopGestureRecognizer].enabled = NO;

    self.delegate = self;
    [self setNavigationBarHidden:YES animated:NO];
}

- (void)setDelegate:(id <UINavigationControllerDelegate>)delegate {
    if (delegate == self || !self.navigationPopGestureRecognizer) {
        [super setDelegate:delegate];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.transitionCoordinator) {
        return NO;
    }

    if (self.viewControllers.count > 1) {
        UIViewController *topVC = self.topViewController;
        if ([topVC isKindOfClass:[HBDViewController class]] && ((HBDViewController *)topVC).forceScreenLandscape) {
            return NO;
        }
        return topVC.hbd_swipeBackEnabled && topVC.hbd_backInteractive;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan {
    id <HBDNavigationTransitionProtocol> target = (id <HBDNavigationTransitionProtocol>) [self superInteractivePopGestureRecognizer].delegate;
    if ([target respondsToSelector:@selector(handleNavigationTransition:)]) {
        [target handleNavigationTransition:pan];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *poppingVC = self.poppingViewController;
    if (poppingVC && [poppingVC isKindOfClass:[HBDViewController class]]) {
        [viewController didReceiveResultCode:poppingVC.resultCode resultData:poppingVC.resultData requestCode:0];
    }

    self.poppingViewController = nil;
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
