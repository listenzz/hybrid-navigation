#import "HBDDrawerController.h"

#import "HBDUtils.h"
#import "UIViewController+HBD.h"

@interface HBDDrawerController () <UIGestureRecognizerDelegate>

@property(nonatomic, assign, getter=isMenuOpened) BOOL menuOpened;
@property(nonatomic, strong) UIView *menuDimmingView;          // 侧边栏半透明黑底
@property(nonatomic, strong) UIView *menuHolderView;

@end

@implementation HBDDrawerController

- (instancetype)initWithContentViewController:(UIViewController *)content menuViewController:(UIViewController *)menu {
    if (self = [super init]) {
        _contentController = content;
        _menuController = menu;
        _menuInteractive = YES;
        _minDrawerMargin = 64;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewController:self.contentController];
    self.contentController.view.frame = self.view.bounds;
    [self.view addSubview:self.contentController.view];
    [self.contentController didMoveToParentViewController:self];

    [self addChildViewController:self.menuController];
    self.menuController.view.frame = CGRectZero;
    [self.menuController didMoveToParentViewController:self];

    UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanGestureRecognizer:)];
    edgePanGestureRecognizer.edges = UIRectEdgeLeft;
    edgePanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:edgePanGestureRecognizer];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.contentController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.menuOpened ? self.menuController : self.contentController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.contentController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.contentController beginAppearanceTransition:YES animated:animated];
    [self.contentController endAppearanceTransition];
    if (self.isMenuOpened) {
        [self.menuController beginAppearanceTransition:YES animated:animated];
        [self.menuController endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.contentController beginAppearanceTransition:NO animated:animated];
    [self.contentController endAppearanceTransition];
    if (self.isMenuOpened) {
        [self.menuController beginAppearanceTransition:NO animated:animated];
        [self.menuController endAppearanceTransition];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)statusBarFrameWillChange:(NSNotification *)notification {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && statusBarHeight != 0) {
        if (self.menuOpened) {
            [UIView animateWithDuration:0.35 animations:^{
                CGFloat dy = [HBDUtils isInCall] ? -20 : 20;
                self.menuHolderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) + dy);
                self.menuDimmingView.frame = self.menuHolderView.bounds;
                self.menuController.view.frame = CGRectMake(0, 0, [self menuWidth], self.menuHolderView.bounds.size.height);
            }];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (self.menuOpened) {
            self.menuHolderView.frame = CGRectMake(0, 0, size.width, size.height);
            self.menuDimmingView.frame = self.menuHolderView.bounds;
            self.menuController.view.frame = CGRectMake(0, 0, [self menuWidth], size.height);
        }
    }                            completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
    }];
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentController = contentViewController;
}

- (void)setMenuViewController:(UIViewController *)menuViewController {
    _menuController = menuViewController;
}

- (void)openMenu {
    if (!self.isMenuOpened) {
        [self presentMenuView];
    }
}

- (void)closeMenu {
    if (self.isMenuOpened) {
        [self dismissMenuView];
    }
}
 
- (void)toggleMenu {
    if (self.isMenuOpened) {
        [self closeMenu];
    } else {
        [self openMenu];
    }
}

- (void)setMenuOpened:(BOOL)menuOpened {
    _menuOpened = menuOpened;
    BOOL hideStatusBar = menuOpened && ![HBDUtils isIphoneX];
    self.menuController.hbd_statusBarHidden = hideStatusBar;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsStatusBarAppearanceUpdate];
    });
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return self.menuInteractive && !self.menuDimmingView;
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) gestureRecognizer;
        return [pan velocityInView:self.menuDimmingView].x < 0;
    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint location = [gestureRecognizer locationInView:self.menuController.view];
        return !CGRectContainsPoint(self.menuController.view.frame, location);
    }
    return NO;
}

- (void)presentMenuView {
    [self addMenuView];

    UIViewController *menu = self.menuController;
    CGFloat menuWidth = [self menuWidth];

    [self.menuController beginAppearanceTransition:YES animated:YES];

    [UIView animateWithDuration:0.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menuDimmingView.alpha = 0.5;
        menu.view.frame = CGRectMake(0, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    }                completion:^(BOOL finished) {
        [self.menuController endAppearanceTransition];
    }];
}

- (void)addMenuView {
    UIViewController *menu = self.menuController;
    CGFloat menuWidth = [self menuWidth];
    menu.view.frame = CGRectMake(-menuWidth, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    UIView *menuHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.menuHolderView = menuHolderView;
    UIView *dimmingView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmingView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:1.0];
    dimmingView.alpha = 0;
    self.menuDimmingView = dimmingView;

    [self.view insertSubview:menuHolderView aboveSubview:self.contentController.view];
    [menuHolderView addSubview:dimmingView];
    [self addGestureRecognizerToMenuHolderView];
    [menuHolderView addSubview:menu.view];
    self.menuOpened = YES;
}

- (void)dismissMenuView {
    self.menuOpened = NO;

    CGFloat menuWidth = [self menuWidth];
    CGFloat dx = -menuWidth - CGRectGetMinX(self.menuController.view.frame);
    CGRect rect = CGRectOffset(self.menuController.view.frame, dx, 0);
    CGFloat duration = (1 - (dx + menuWidth) / menuWidth) * 0.2;

    [self.menuController beginAppearanceTransition:NO animated:YES];

    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuController.view.frame = rect;
        self.menuDimmingView.alpha = 0;
    }                completion:^(BOOL finished) {
        [self.menuController.view removeFromSuperview];
        [self.menuDimmingView removeFromSuperview];
        self.menuDimmingView = nil;
        [self.menuHolderView removeFromSuperview];
        self.menuHolderView = nil;
        [self.menuController endAppearanceTransition];
    }];
}

- (void)settleMuneView {
    CGFloat width = CGRectGetWidth(self.menuController.view.frame);
    CGFloat dx = 0 - CGRectGetMinX(self.menuController.view.frame);
    CGRect rect = CGRectOffset(self.menuController.view.frame, dx, 0);
    CGFloat duration = (dx / width) * 0.2;
    [self.menuController beginAppearanceTransition:YES animated:YES];
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuController.view.frame = rect;
        self.menuDimmingView.alpha = 0.5;
    }                completion:^(BOOL finished) {
        [self.menuController endAppearanceTransition];
    }];
}

- (void)addGestureRecognizerToMenuHolderView {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGestureRecognizer.delegate = self;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];

    [self.menuHolderView addGestureRecognizer:panGestureRecognizer];
    [self.menuHolderView addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleEdgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat dx = [recognizer translationInView:self.view].x;
    CGFloat width = [self menuWidth];
    dx = MIN(dx, width);
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        [self addMenuView];
        self.menuController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
        self.menuDimmingView.alpha = dx * 0.5 / width;
    } else if (UIGestureRecognizerStateChanged == recognizer.state) {
        self.menuController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
        self.menuDimmingView.alpha = dx * 0.5 / width;
    } else {
        if (dx / width < 0.2) {
            [self dismissMenuView];
        } else {
            [self settleMuneView];
        }
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGFloat dx = [recognizer translationInView:self.menuDimmingView].x;
    CGFloat width = CGRectGetWidth(self.menuController.view.bounds);
    CGFloat height = CGRectGetHeight(self.menuController.view.bounds);
    dx = MIN(0, MAX(-width, dx));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.menuController.view.frame = CGRectMake(dx, 0, width, height);
        self.menuDimmingView.alpha = (dx + width) * 0.5 / width;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.menuController.view.frame = CGRectMake(dx, 0, width, height);
        self.menuDimmingView.alpha = (dx + width) * 0.5 / width;
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (dx / -width > 0.2) {
            [self dismissMenuView];
        } else {
            [self settleMuneView];
        }
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [self dismissMenuView];
}

- (CGFloat)menuWidth {
    CGFloat maxWidth = CGRectGetWidth(self.view.bounds);
    CGFloat margin1 = self.minDrawerMargin;
    if (margin1 > maxWidth) {
        margin1 = maxWidth;
    } else if (margin1 < 0) {
        margin1 = 0;
    }
    if (self.maxDrawerWidth <= 0 || self.maxDrawerWidth > maxWidth) {
        self.maxDrawerWidth = maxWidth;
    }
    CGFloat margin2 = maxWidth - self.maxDrawerWidth;
    CGFloat margin = MAX(margin1, margin2);
    return maxWidth - margin;
}

@end
