#import "HBDDrawerController.h"

#import "HBDUtils.h"
#import "UIViewController+HBD.h"

static const NSTimeInterval HBDDrawerAnimationDuration = 0.28;
static const CGFloat HBDDrawerLegacyContentCornerRadius = 39.0;
static const CGFloat HBDDrawerModernPhoneContentCornerRadius = 55.0;
static const CGFloat HBDDrawerModernPadContentCornerRadius = 24.0;
static const CGFloat HBDDrawerContentShadowOpacity = 0.16;
static const CGFloat HBDDrawerContentDimmingAlpha = 0.08;
static const CGFloat HBDDrawerOpenGestureWidth = 200.0;
static const CGFloat HBDDrawerOpenGestureActivationDistance = 24.0;
static const CGFloat HBDDrawerHorizontalActivationRatio = 1.2;
static const CGFloat HBDDrawerOpenSettleThreshold = 0.22;
static const CGFloat HBDDrawerCloseSettleThreshold = 0.78;
static const CGFloat HBDDrawerSettleVelocity = 350.0;
static const CGFloat HBDDrawerMenuOverlayMaxAlpha = 0.34;

@interface HBDDrawerController () <UIGestureRecognizerDelegate>

@property(nonatomic, assign, getter=isMenuOpened) BOOL menuOpened;
@property(nonatomic, strong) UIView *menuHolderView;
@property(nonatomic, strong) UIView *menuGradientOverlayView;
@property(nonatomic, strong) CAGradientLayer *menuGradientOverlayLayer;
@property(nonatomic, strong) UIView *contentWrapperView;
@property(nonatomic, strong) UIView *contentClippingView;
@property(nonatomic, strong) CAShapeLayer *contentClippingMaskLayer;
@property(nonatomic, strong) UIView *contentDimmingView;
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *openPanGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *contentPanGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *menuPanGestureRecognizer;
@property(nonatomic, strong) UITapGestureRecognizer *contentTapGestureRecognizer;
@property(nonatomic, strong) UIGestureRecognizer *activeOpeningGestureRecognizer;
@property(nonatomic, strong) UIImpactFeedbackGenerator *drawerFeedbackGenerator;
@property(nonatomic, assign) CGFloat drawerProgress;
@property(nonatomic, assign) BOOL openPanStartedNearEdge;
@property(nonatomic, assign) BOOL openingGestureHasDrawer;
@property(nonatomic, assign) BOOL openingGestureAppearanceTransitionInProgress;

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

    self.contentWrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentWrapperView.layer.masksToBounds = NO;
    self.contentWrapperView.layer.shadowColor = UIColor.blackColor.CGColor;
    self.contentWrapperView.layer.shadowOffset = CGSizeMake(-8, 0);
    self.contentWrapperView.layer.shadowRadius = 24;
    self.contentWrapperView.layer.shadowOpacity = 0;

    self.contentClippingView = [[UIView alloc] initWithFrame:self.contentWrapperView.bounds];
    self.contentClippingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentClippingView.layer.masksToBounds = YES;
    if (@available(iOS 13.0, *)) {
        self.contentClippingView.layer.cornerCurve = kCACornerCurveContinuous;
    }
    [self.contentWrapperView addSubview:self.contentClippingView];

    [self addChildViewController:self.contentController];
    self.contentController.view.frame = self.contentClippingView.bounds;
    self.contentController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentClippingView addSubview:self.contentController.view];
    [self.view addSubview:self.contentWrapperView];
    [self.contentController didMoveToParentViewController:self];

    UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanGestureRecognizer:)];
    edgePanGestureRecognizer.edges = UIRectEdgeLeft;
    edgePanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:edgePanGestureRecognizer];
    self.edgePanGestureRecognizer = edgePanGestureRecognizer;

    UIPanGestureRecognizer *openPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOpenPanGestureRecognizer:)];
    openPanGestureRecognizer.delegate = self;
    openPanGestureRecognizer.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:openPanGestureRecognizer];
    self.openPanGestureRecognizer = openPanGestureRecognizer;
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self applyDrawerProgress:self.drawerProgress];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (self.menuHolderView) {
            self.menuHolderView.frame = CGRectMake(0, 0, size.width, size.height);
            self.menuController.view.frame = CGRectMake(0, 0, [self menuWidth], size.height);
            [self applyDrawerProgress:self.drawerProgress];
        }
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {

    }];
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
        return [self canOpenMenuByGesture];
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) gestureRecognizer;
        CGPoint velocity = [pan velocityInView:self.view];
        if (gestureRecognizer == self.openPanGestureRecognizer) {
            return [self canOpenMenuByGesture] && self.openPanStartedNearEdge && [self shouldBeginOpeningPanGestureRecognizer:pan];
        }
        BOOL isDrawerClosingPan = gestureRecognizer == self.contentPanGestureRecognizer || gestureRecognizer == self.menuPanGestureRecognizer;
        return isDrawerClosingPan && self.isMenuOpened && velocity.x < 0 && ABS(velocity.x) > ABS(velocity.y) * HBDDrawerHorizontalActivationRatio;
    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return gestureRecognizer == self.contentTapGestureRecognizer && self.isMenuOpened;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.openPanGestureRecognizer) {
        CGPoint location = [touch locationInView:self.view];
        self.openPanStartedNearEdge = location.x <= HBDDrawerOpenGestureWidth;
        return YES;
    }
    return YES;
}

- (void)presentMenuView {
    [self removeMenuView];
    [self cancelReactTouches];
    [self addMenuView];

    UIViewController *menu = self.menuController;

    [self.menuController beginAppearanceTransition:YES animated:YES];

    [UIView animateWithDuration:HBDDrawerAnimationDuration delay:0. options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        [self applyDrawerProgress:1];
    }                completion:^(BOOL finished) {
        [self.menuController endAppearanceTransition];
        menu.view.userInteractionEnabled = YES;
    }];
}

- (void)addMenuView {
    UIViewController *menu = self.menuController;
    CGFloat menuWidth = [self menuWidth];

    UIView *menuHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
    menuHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    menuHolderView.backgroundColor = [UIColor colorWithRed:0.96 green:0.94 blue:0.90 alpha:1.0];
    self.menuHolderView = menuHolderView;

    [self.view insertSubview:menuHolderView belowSubview:self.contentWrapperView];
    [self.view bringSubviewToFront:self.contentWrapperView];

    BOOL shouldMoveToParent = menu.parentViewController != self;
    if (shouldMoveToParent) {
        [self addChildViewController:menu];
    }

    menu.view.frame = CGRectMake(0, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    menu.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    menu.view.userInteractionEnabled = NO;
    [menuHolderView addSubview:menu.view];
    if (shouldMoveToParent) {
        [menu didMoveToParentViewController:self];
    }

    UIView *menuGradientOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    menuGradientOverlayView.userInteractionEnabled = NO;
    CAGradientLayer *menuGradientOverlayLayer = [CAGradientLayer layer];
    menuGradientOverlayLayer.startPoint = CGPointMake(0, 0.5);
    menuGradientOverlayLayer.endPoint = CGPointMake(1, 0.5);
    menuGradientOverlayLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:0 alpha:HBDDrawerMenuOverlayMaxAlpha * 0.32].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:HBDDrawerMenuOverlayMaxAlpha * 0.6].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:HBDDrawerMenuOverlayMaxAlpha].CGColor
    ];
    menuGradientOverlayLayer.locations = @[@0, @0.55, @1];
    [menuGradientOverlayView.layer addSublayer:menuGradientOverlayLayer];
    [menuHolderView addSubview:menuGradientOverlayView];
    self.menuGradientOverlayView = menuGradientOverlayView;
    self.menuGradientOverlayLayer = menuGradientOverlayLayer;

    UIView *contentDimmingView = [[UIView alloc] initWithFrame:self.contentController.view.bounds];
    contentDimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentDimmingView.backgroundColor = UIColor.blackColor;
    contentDimmingView.userInteractionEnabled = YES;
    contentDimmingView.alpha = 0;
    [self.contentController.view addSubview:contentDimmingView];
    self.contentDimmingView = contentDimmingView;

    [self addGestureRecognizerToContentWrapperView];
    [self addGestureRecognizerToMenuHolderView];
    self.contentController.view.accessibilityElementsHidden = YES;
    self.menuOpened = YES;
    [self applyDrawerProgress:0];
}

- (void)dismissMenuView {
    [self dismissMenuViewWithAppearanceTransition:YES];
}

- (void)dismissMenuViewWithAppearanceTransition:(BOOL)appearanceTransition {
    self.menuOpened = NO;
    [self cancelReactTouches];

    CGFloat duration = MAX(0.08, HBDDrawerAnimationDuration * self.drawerProgress);

    if (self.openingGestureAppearanceTransitionInProgress) {
        [self.menuController endAppearanceTransition];
        self.openingGestureAppearanceTransitionInProgress = NO;
        appearanceTransition = YES;
    }

    if (appearanceTransition) {
        [self.menuController beginAppearanceTransition:NO animated:YES];
    }

    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        [self applyDrawerProgress:0];
    }                completion:^(BOOL finished) {
        if (appearanceTransition) {
            [self.menuController endAppearanceTransition];
        }
        [self removeMenuView];
    }];
}

- (void)removeMenuView {
    [self removeGestureRecognizerFromContentWrapperView];
    [self removeGestureRecognizerFromMenuHolderView];
    [self applyDrawerProgress:0];
    BOOL isMenuViewLoaded = self.menuController.isViewLoaded;
    BOOL shouldRemoveFromParent = self.menuController.parentViewController == self;
    if (shouldRemoveFromParent) {
        [self.menuController willMoveToParentViewController:nil];
    }
    if (isMenuViewLoaded) {
        [self.menuController.view removeFromSuperview];
        self.menuController.view.transform = CGAffineTransformIdentity;
    }
    if (shouldRemoveFromParent) {
        [self.menuController removeFromParentViewController];
    }
    [self.contentDimmingView removeFromSuperview];
    self.contentDimmingView = nil;
    self.menuGradientOverlayView = nil;
    self.menuGradientOverlayLayer = nil;
    self.contentController.view.accessibilityElementsHidden = NO;
    [self.menuHolderView removeFromSuperview];
    self.menuHolderView = nil;
}

- (void)settleMenuViewWithAppearanceTransition:(BOOL)appearanceTransition {
    CGFloat duration = MAX(0.08, HBDDrawerAnimationDuration * (1 - self.drawerProgress));
    [self cancelReactTouches];
    if (appearanceTransition && !self.openingGestureAppearanceTransitionInProgress) {
        [self.menuController beginAppearanceTransition:YES animated:YES];
    }
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        [self applyDrawerProgress:1];
    }                completion:^(BOOL finished) {
        self.menuController.view.userInteractionEnabled = YES;
        if (appearanceTransition) {
            [self.menuController endAppearanceTransition];
            self.openingGestureAppearanceTransitionInProgress = NO;
        }
    }];
}

- (void)addGestureRecognizerToContentWrapperView {
    if (self.contentPanGestureRecognizer || self.contentTapGestureRecognizer) {
        return;
    }

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGestureRecognizer.delegate = self;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    tapGestureRecognizer.delaysTouchesBegan = YES;
    tapGestureRecognizer.delaysTouchesEnded = YES;
    [tapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];

    [self.contentWrapperView addGestureRecognizer:panGestureRecognizer];
    [self.contentWrapperView addGestureRecognizer:tapGestureRecognizer];
    self.contentPanGestureRecognizer = panGestureRecognizer;
    self.contentTapGestureRecognizer = tapGestureRecognizer;
}

- (void)addGestureRecognizerToMenuHolderView {
    if (self.menuPanGestureRecognizer) {
        return;
    }

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.cancelsTouchesInView = NO;

    [self.menuController.view addGestureRecognizer:panGestureRecognizer];
    self.menuPanGestureRecognizer = panGestureRecognizer;
}

- (void)removeGestureRecognizerFromContentWrapperView {
    if (self.contentPanGestureRecognizer) {
        [self.contentWrapperView removeGestureRecognizer:self.contentPanGestureRecognizer];
        self.contentPanGestureRecognizer = nil;
    }
    if (self.contentTapGestureRecognizer) {
        [self.contentWrapperView removeGestureRecognizer:self.contentTapGestureRecognizer];
        self.contentTapGestureRecognizer = nil;
    }
}

- (void)removeGestureRecognizerFromMenuHolderView {
    if (self.menuPanGestureRecognizer) {
        [self.menuController.view removeGestureRecognizer:self.menuPanGestureRecognizer];
        self.menuPanGestureRecognizer = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer == self.menuPanGestureRecognizer || otherGestureRecognizer == self.menuPanGestureRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.edgePanGestureRecognizer || gestureRecognizer == self.openPanGestureRecognizer) {
        return [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
               [self isGestureRecognizer:otherGestureRecognizer attachedInsideView:self.contentController.view];
    }

    return NO;
}

- (BOOL)isGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer attachedInsideView:(UIView *)view {
    UIView *gestureView = gestureRecognizer.view;
    return gestureView == view || [gestureView isDescendantOfView:view];
}

- (void)handleEdgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
    [self handleOpeningPanGestureRecognizer:recognizer];
}

- (void)handleOpenPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    [self handleOpeningPanGestureRecognizer:recognizer];
}

- (void)handleOpeningPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.activeOpeningGestureRecognizer && self.activeOpeningGestureRecognizer != recognizer) {
            return;
        }
        self.activeOpeningGestureRecognizer = recognizer;
        self.openingGestureHasDrawer = NO;
    } else if (self.activeOpeningGestureRecognizer && self.activeOpeningGestureRecognizer != recognizer) {
        return;
    }

    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat dx = translation.x;
    CGFloat width = [self menuWidth];
    CGFloat progress = MIN(1, MAX(0, dx / width));
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [self beginOpeningDrawerWithProgress:progress];
        }
    } else if (UIGestureRecognizerStateChanged == recognizer.state) {
        if (!self.openingGestureHasDrawer) {
            if (![self shouldActivateOpeningGestureRecognizer:recognizer translation:translation]) {
                return;
            }
            [self beginOpeningDrawerWithProgress:progress];
        }
        [self applyDrawerProgress:progress];
    } else {
        if (!self.openingGestureHasDrawer) {
            [self finishOpeningGestureRecognizer:recognizer];
            return;
        }
        CGFloat velocity = [recognizer velocityInView:self.view].x;
        if (progress < HBDDrawerOpenSettleThreshold && velocity < HBDDrawerSettleVelocity) {
            [self cancelDrawerHapticFeedback];
            [self dismissMenuViewWithAppearanceTransition:NO];
        } else {
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                [self triggerDrawerHapticFeedback];
            } else {
                [self cancelDrawerHapticFeedback];
            }
            [self settleMenuViewWithAppearanceTransition:YES];
        }
        [self finishOpeningGestureRecognizer:recognizer];
    }
}

- (BOOL)shouldActivateOpeningGestureRecognizer:(UIPanGestureRecognizer *)recognizer translation:(CGPoint)translation {
    if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }

    CGPoint velocity = [recognizer velocityInView:self.view];
    BOOL movedFarEnough = translation.x > HBDDrawerOpenGestureActivationDistance;
    BOOL movingRight = translation.x > 0 || velocity.x > 0;
    BOOL mostlyHorizontal = ABS(translation.x) > ABS(translation.y) * HBDDrawerHorizontalActivationRatio ||
            ABS(velocity.x) > ABS(velocity.y) * HBDDrawerHorizontalActivationRatio;
    return movedFarEnough && movingRight && mostlyHorizontal;
}

- (BOOL)shouldBeginOpeningPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:self.view];
    return velocity.x > 0 && ABS(velocity.x) > ABS(velocity.y) * HBDDrawerHorizontalActivationRatio;
}

- (void)beginOpeningDrawerWithProgress:(CGFloat)progress {
    self.openingGestureHasDrawer = YES;
    [self cancelReactTouches];
    [self prepareDrawerHapticFeedback];
    [self addMenuView];
    if (!self.openingGestureAppearanceTransitionInProgress) {
        [self.menuController beginAppearanceTransition:YES animated:YES];
        self.openingGestureAppearanceTransitionInProgress = YES;
    }
    [self applyDrawerProgress:progress];
}

- (void)finishOpeningGestureRecognizer:(UIGestureRecognizer *)recognizer {
    if (recognizer == self.openPanGestureRecognizer) {
        self.openPanStartedNearEdge = NO;
    }
    self.activeOpeningGestureRecognizer = nil;
    self.openingGestureHasDrawer = NO;
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGFloat dx = [recognizer translationInView:self.view].x;
    CGFloat width = [self menuWidth];
    CGFloat progress = MIN(1, MAX(0, 1 + dx / width));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self cancelReactTouches];
        [self prepareDrawerHapticFeedback];
        [self applyDrawerProgress:progress];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self applyDrawerProgress:progress];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocity = [recognizer velocityInView:self.view].x;
        if (progress < HBDDrawerCloseSettleThreshold || velocity < -HBDDrawerSettleVelocity) {
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                [self triggerDrawerHapticFeedback];
            } else {
                [self cancelDrawerHapticFeedback];
            }
            [self dismissMenuView];
        } else {
            [self cancelDrawerHapticFeedback];
            [self settleMenuViewWithAppearanceTransition:NO];
        }
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [self cancelReactTouches];
    [self dismissMenuView];
}

- (BOOL)canOpenMenuByGesture {
    return self.menuInteractive && !self.menuHolderView && [self isContentStackRoot];
}

- (BOOL)isContentStackRoot {
    UIViewController *content = [self currentContentControllerForDrawerGesture];
    if ([content isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)content).viewControllers.count <= 1;
    }

    UINavigationController *navigationController = content.navigationController;
    if (navigationController) {
        return navigationController.viewControllers.count <= 1 || navigationController.topViewController == navigationController.viewControllers.firstObject;
    }

    return YES;
}

- (UIViewController *)currentContentControllerForDrawerGesture {
    UIViewController *content = self.contentController;
    if ([content isKindOfClass:[UITabBarController class]]) {
        UIViewController *selected = ((UITabBarController *)content).selectedViewController;
        return selected ?: content;
    }
    return content;
}

- (void)cancelReactTouches {
    [self cancelReactTouchesInView:self.contentController.view];
    if (self.menuController.isViewLoaded) {
        [self cancelReactTouchesInView:self.menuController.view];
    }
}

- (void)cancelReactTouchesInView:(UIView *)view {
    if (!view) {
        return;
    }

    for (UIGestureRecognizer *gestureRecognizer in view.gestureRecognizers) {
        if ([self isReactTouchHandlerGestureRecognizer:gestureRecognizer]) {
            gestureRecognizer.enabled = NO;
            gestureRecognizer.enabled = YES;
        }
    }

    for (UIView *subview in view.subviews) {
        [self cancelReactTouchesInView:subview];
    }
}

- (BOOL)isReactTouchHandlerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    Class surfaceTouchHandlerClass = NSClassFromString(@"RCTSurfaceTouchHandler");
    if (surfaceTouchHandlerClass && [gestureRecognizer isKindOfClass:surfaceTouchHandlerClass]) {
        return YES;
    }

    Class touchHandlerClass = NSClassFromString(@"RCTTouchHandler");
    return touchHandlerClass && [gestureRecognizer isKindOfClass:touchHandlerClass];
}

- (void)prepareDrawerHapticFeedback {
    self.drawerFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [self.drawerFeedbackGenerator prepare];
}

- (void)triggerDrawerHapticFeedback {
    [self.drawerFeedbackGenerator impactOccurred];
    self.drawerFeedbackGenerator = nil;
}

- (void)cancelDrawerHapticFeedback {
    self.drawerFeedbackGenerator = nil;
}

- (void)applyDrawerProgress:(CGFloat)progress {
    progress = MIN(1, MAX(0, progress));
    self.drawerProgress = progress;

    CGFloat menuWidth = [self menuWidth];
    CGFloat height = CGRectGetHeight(self.view.bounds);

    if (self.menuHolderView) {
        self.menuHolderView.frame = self.view.bounds;
        self.menuController.view.frame = CGRectMake(0, 0, menuWidth, height);
        self.menuController.view.transform = CGAffineTransformIdentity;
        self.menuController.view.alpha = 1;

        self.menuGradientOverlayView.frame = CGRectMake(0, 0, menuWidth, height);
        self.menuGradientOverlayLayer.frame = self.menuGradientOverlayView.bounds;
        self.menuGradientOverlayView.alpha = 1 - progress;
    }

    CGRect bounds = self.view.bounds;
    self.contentWrapperView.bounds = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    self.contentWrapperView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    self.contentWrapperView.transform = CGAffineTransformMakeTranslation(menuWidth * progress, 0);
    self.contentClippingView.frame = self.contentWrapperView.bounds;
    self.contentController.view.frame = self.contentClippingView.bounds;
    self.contentDimmingView.frame = self.contentController.view.bounds;
    self.contentDimmingView.alpha = HBDDrawerContentDimmingAlpha * progress;

    CGFloat cornerRadius = [self contentCornerRadiusForDrawerProgress:progress];
    BOOL usesShapeMask = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 260000
    if (@available(iOS 26.0, *)) {
        usesShapeMask = YES;
        if (progress > 0) {
            if (!self.contentClippingMaskLayer) {
                self.contentClippingMaskLayer = [CAShapeLayer layer];
            }
            self.contentClippingMaskLayer.frame = self.contentClippingView.bounds;
            self.contentClippingMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.contentClippingView.bounds cornerRadius:cornerRadius].CGPath;
            self.contentClippingView.layer.mask = self.contentClippingMaskLayer;
        } else {
            self.contentClippingView.layer.mask = nil;
        }
    }
#endif
    if (!usesShapeMask) {
        self.contentClippingView.layer.mask = nil;
    }
    self.contentWrapperView.layer.cornerRadius = cornerRadius;
    self.contentClippingView.layer.cornerRadius = cornerRadius;
    self.contentClippingView.layer.masksToBounds = progress > 0;
    self.contentWrapperView.layer.shadowPath = progress > 0 ? [UIBezierPath bezierPathWithRoundedRect:self.contentWrapperView.bounds cornerRadius:cornerRadius].CGPath : nil;
    if (@available(iOS 13.0, *)) {
        self.contentWrapperView.layer.cornerCurve = kCACornerCurveContinuous;
        self.contentClippingView.layer.cornerCurve = kCACornerCurveContinuous;
    }

    self.contentWrapperView.layer.shadowOpacity = HBDDrawerContentShadowOpacity * progress;
}

- (CGFloat)contentCornerRadiusForDrawerProgress:(CGFloat)progress {
    if (progress <= 0) {
        return 0;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 260000
    if (@available(iOS 26.0, *)) {
        CGFloat minDimension = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        return minDimension <= 600 ? HBDDrawerModernPhoneContentCornerRadius : HBDDrawerModernPadContentCornerRadius;
    }
#endif

    return HBDDrawerLegacyContentCornerRadius;
}

- (CGFloat)menuWidth {
    CGFloat maxWidth = CGRectGetWidth(self.view.bounds);
    CGFloat margin1 = self.minDrawerMargin;
    if (margin1 > maxWidth) {
        margin1 = maxWidth;
    } else if (margin1 < 0) {
        margin1 = 0;
    }
    CGFloat maxDrawerWidth = self.maxDrawerWidth;
    if (maxDrawerWidth <= 0 || maxDrawerWidth > maxWidth) {
        maxDrawerWidth = maxWidth;
    }
    CGFloat margin2 = maxWidth - maxDrawerWidth;
    CGFloat margin = MAX(margin1, margin2);
    return maxWidth - margin;
}

@end
