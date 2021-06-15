//
//  HBDModalViewController.m
//  HybridNavigation
//  fork from https://github.com/Tencent/QMUI_iOS/blob/master/QMUIKit/QMUIComponents/QMUIModalPresentationViewController.m
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <React/RCTLog.h>
#import <objc/runtime.h>
#import "HBDModalViewController.h"
#import "HBDRootView.h"
#import "HBDUtils.h"

@interface UIViewController()

@property(nonatomic, weak, readwrite) HBDModalViewController *hbd_modalViewController;
@property(nonatomic, strong, readwrite) UIViewController *hbd_targetViewController;
@property(nonatomic, weak, readwrite) UIViewController *hbd_popupViewController;

@end

@interface HBDModalViewController ()

@property(nonatomic, assign, readwrite, getter=isBeingHidden) BOOL beingHidden;

@property (nonatomic, strong, readwrite) UIView *contentView;

@property(nonatomic, strong) HBDModalWindow *modalWindow;
@property(nonatomic, weak, readwrite) UIWindow *previousKeyWindow;
@property(nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGestureRecognizer;

@end

@implementation HBDModalViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    self.animationStyle = HBDModalAnimationStyleFade;
    self.contentViewMargins = UIEdgeInsetsZero;
    self.maximumContentViewWidth = [UIScreen mainScreen].bounds.size.width;
    [self initDefaultDimmingViewWithoutAddToView];
}

- (void)dealloc {
    self.modalWindow = nil;
    RCTLogInfo(@"[Navigator] %s", __FUNCTION__);
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.contentViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.contentViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    if (self.dimmingView && !self.dimmingView.superview) {
        [self.view addSubview:self.dimmingView];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.dimmingView.frame = self.view.bounds;
    if ([HBDUtils isInCall]) {
        self.dimmingView.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 20);
    }
    CGRect contentViewFrame = [self contentViewFrameForShowing];
    if (self.layoutBlock) {
        self.layoutBlock(self, contentViewFrame);
    } else {
        self.contentView.frame = contentViewFrame;
    }
}

- (CGRect)contentViewFrameForShowing {
    if ([self.contentView isKindOfClass:[HBDRootView class]]) {
        return self.view.bounds;
    }
    CGSize contentViewContainerSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - self.contentViewMargins.left - self.contentViewMargins.right, CGRectGetHeight(self.view.bounds)  - self.contentViewMargins.top - self.contentViewMargins.bottom);
    CGSize contentViewLimitSize = CGSizeMake(fmin(self.maximumContentViewWidth, contentViewContainerSize.width), contentViewContainerSize.height);
    CGSize contentViewSize = CGSizeZero;
    if (self.measureBlock) {
        contentViewSize = self.measureBlock(self, contentViewLimitSize);
    } else {
        contentViewSize = [self.contentView sizeThatFits:contentViewLimitSize];
    }
    contentViewSize.width = fmin(contentViewLimitSize.width, contentViewSize.width);
    contentViewSize.height = fmin(contentViewLimitSize.height, contentViewSize.height);
    CGRect contentViewFrame = CGRectMake((contentViewContainerSize.width - contentViewSize.width)/2 + self.contentViewMargins.left, (contentViewContainerSize.height-contentViewSize.height)/2 + self.contentViewMargins.top, contentViewSize.width, contentViewSize.height);
    contentViewFrame = CGRectApplyAffineTransform(contentViewFrame, self.contentView.transform);
    return contentViewFrame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:)name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)statusBarFrameWillChange:(NSNotification*)notification {
    [UIView animateWithDuration:0.35 animations:^{
        CGFloat dy = [HBDUtils isInCall] ? -20 : 20;
        self.dimmingView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) + dy);
    }];
}

- (void)updateLayout {
    if ([self isViewLoaded]) {
        [self.view setNeedsLayout];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            self.view.frame = CGRectMake(0, 0, size.width, size.height);
        }
        [self updateLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

#pragma mark - Dimming View

- (void)setDimmingView:(UIView *)dimmingView {
    if (![self isViewLoaded]) {
        _dimmingView = dimmingView;
    } else {
        [self.view insertSubview:dimmingView belowSubview:_dimmingView];
        [_dimmingView removeFromSuperview];
        _dimmingView = dimmingView;
        [self.view setNeedsLayout];
    }
    [self addTapGestureRecognizerToDimmingViewIfNeeded];
}

- (void)initDefaultDimmingViewWithoutAddToView {
    if (!self.dimmingView) {
        _dimmingView = [[UIView alloc] init];
        self.dimmingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
        [self addTapGestureRecognizerToDimmingViewIfNeeded];
        if ([self isViewLoaded]) {
            [self.view addSubview:self.dimmingView];
        }
    }
}

// 要考虑用户可能创建了自己的dimmingView，则tap手势也要重新添加上去
- (void)addTapGestureRecognizerToDimmingViewIfNeeded {
    if (!self.dimmingView) {
        return;
    }
    
    if (self.dimmingViewTapGestureRecognizer.view == self.dimmingView) {
        return;
    }
    
    if (!self.dimmingViewTapGestureRecognizer) {
        self.dimmingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDimmingViewTapGestureRecognizer:)];
    }
    [self.dimmingView addGestureRecognizer:self.dimmingViewTapGestureRecognizer];
    self.dimmingView.userInteractionEnabled = YES;// UIImageView默认userInteractionEnabled为NO，为了兼容UIImageView，这里必须主动设置为YES
}

- (void)handleDimmingViewTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.contentViewController hbd_hideViewControllerAnimated:YES completion:nil];
}

#pragma mark - ContentView

- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;
    if (contentViewController) {
        _contentViewController.hbd_modalViewController = self;
        [self addChildViewController:contentViewController];
        [contentViewController didMoveToParentViewController:self];
    }
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    if ([contentView isKindOfClass:[HBDRootView class]]) {
        HBDRootView *rootView = (HBDRootView *)contentView;
        rootView.backgroundColor = UIColor.clearColor;
    }
}

#pragma mark - Showing and Hiding

- (void)showingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == HBDModalAnimationStyleFade) {
        self.dimmingView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == HBDModalAnimationStylePopup) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == HBDModalAnimationStyleSlide) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
}

- (void)hidingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == HBDModalAnimationStyleFade) {
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else if (self.animationStyle == HBDModalAnimationStylePopup) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    } else if (self.animationStyle == HBDModalAnimationStyleSlide) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    }
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.contentView = self.contentViewController.view;
    self.previousKeyWindow = self.contentViewController.hbd_targetViewController.view.window;
    
    if (!self.modalWindow) {
        self.modalWindow = [[HBDModalWindow alloc] init];
        self.modalWindow.windowLevel = UIWindowLevelAlert - 4.0;;
        self.modalWindow.backgroundColor = UIColor.clearColor;// 避免横竖屏旋转时出现黑色
    }
    
    self.modalWindow.rootViewController = self;
    [self.modalWindow makeKeyAndVisible];
    
    void (^didShownCompletion)(BOOL finished) = ^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        [self.view addSubview:self.contentView];
        [self.view layoutIfNeeded];
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        if (self.showingAnimation) {
            // 使用自定义的动画
            if (self.layoutBlock) {
                self.layoutBlock(self, contentViewFrame);
                contentViewFrame = self.contentView.frame;
            }
            self.showingAnimation(self, contentViewFrame, didShownCompletion);
        } else {
            self.contentView.frame = contentViewFrame;
            [self.contentView setNeedsLayout];
            [self.contentView layoutIfNeeded];
            [self showingAnimationWithCompletion:didShownCompletion];
        }
    } else {
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        self.contentView.frame = contentViewFrame;
        [self.view addSubview:self.contentView];
        self.dimmingView.alpha = 1;
        didShownCompletion(YES);
    }
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.beingHidden = YES;
    [self.view endEditing:YES];
    
    if (RCTKeyWindow() == self.modalWindow) {
        if (self.previousKeyWindow) {
            [self.previousKeyWindow makeKeyWindow];
        } else {
            [[UIApplication sharedApplication].delegate.window makeKeyWindow];
        }
    }
    
    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:NO animated:animated];
    }
    
    void (^didHiddenCompletion)(BOOL finished) = ^(BOOL finished) {
        
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.modalWindow.hidden = YES;
        self.modalWindow.rootViewController = nil;
        self.previousKeyWindow = nil;

        if (self.willDismissBlock) {
            self.willDismissBlock(self);
        }
        
        if (completion) {
            completion(YES);
        }
        
        if (self.contentViewController) {
            self.contentViewController.hbd_targetViewController.hbd_popupViewController = nil;
            self.contentViewController.hbd_targetViewController = nil;
            self.contentViewController.hbd_modalViewController = nil;
            self.contentViewController = nil;
        }
    };
    
    if (animated) {
        if (self.hidingAnimation) {
            self.hidingAnimation(self, didHiddenCompletion);
        } else {
            [self hidingAnimationWithCompletion:didHiddenCompletion];
        }
    } else {
        didHiddenCompletion(YES);
    }
}

@end

@interface HBDModalViewController(Manager)
- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
@end

@implementation HBDModalWindow

@end

@implementation UIViewController (HBDModalViewController)

- (HBDModalViewController *)hbd_modalViewController {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_modalViewController:(HBDModalViewController *)modalViewController {
    objc_setAssociatedObject(self, @selector(hbd_modalViewController), modalViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)hbd_targetViewController {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_targetViewController:(UIViewController *)targetViewController {
    objc_setAssociatedObject(self, @selector(hbd_targetViewController), targetViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)hbd_popupViewController {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_popupViewController:(UIViewController *)puppetViewController {
    objc_setAssociatedObject(self, @selector(hbd_popupViewController), puppetViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hbd_showViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self hbd_showViewController:vc requestCode:0 animated:animated completion:completion];
}

- (void)hbd_showViewController:(UIViewController *)vc requestCode:(NSInteger)requestCode animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (![self canShowModal]) {
        if (completion) {
            completion(NO);
        }
        [self didReceiveResultCode:0 resultData:nil requestCode:requestCode];
        return;
    }
    
    self.hbd_popupViewController = vc;
    [self beginAppearanceTransition:NO animated:YES];
    [self endAppearanceTransition];
    
    vc.hbd_barStyle = self.hbd_barStyle;
    vc.hbd_targetViewController = self;
    vc.requestCode = requestCode;
    
    HBDModalViewController *modalViewController = [[HBDModalViewController alloc] init];
    modalViewController.contentViewController = vc;
    [modalViewController showWithAnimated:animated completion:completion];
}

- (BOOL)canShowModal {
    UIViewController *presented = self.presentedViewController;
    if (presented && !presented.isBeingDismissed) {
        RCTLogWarn(@"[Navigator] Can't show modal since the scene had present another scene already.");
        return NO;
    }
    
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        UIViewController *viewController = window.rootViewController;
        if ([viewController isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)viewController;
            if (!modal.beingHidden && window != self.view.window) {
                RCTLogWarn(@"[Navigator] Can't show modal since the scene had show another modal already.");
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)hbd_hideViewControllerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (!self.hbd_modalViewController) {
        UIViewController *parent = self.parentViewController;
        parent.resultData = self.resultData;
        parent.resultCode = self.resultCode;
        [parent hbd_hideViewControllerAnimated:animated completion:completion];
        return;
    }
    
    [self.hbd_modalViewController hideWithAnimated:animated completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        UIViewController *target = self.hbd_targetViewController;
        [target beginAppearanceTransition:YES animated:YES];
        [target endAppearanceTransition];
        [target didReceiveResultCode:self.resultCode resultData:self.resultData requestCode:self.requestCode];
    }];
}

@end


