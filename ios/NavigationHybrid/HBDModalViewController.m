//
//  HBDModalViewController.m
//  NavigationHybrid
//
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <React/RCTLog.h>
#import <objc/runtime.h>
#import "HBDModalViewController.h"
#import "HBDRootView.h"

@interface UIViewController()

@property(nonatomic, weak, readwrite) HBDModalViewController *hbd_modalViewController;
@property(nonatomic, strong, readwrite) UIViewController *hbd_targetViewController;
@property(nonatomic, weak, readwrite) UIViewController *hbd_popupViewController;

@end

@interface HBDModalViewController ()

@property (nonatomic, strong, readwrite) UIView *contentView;

@property(nonatomic, strong) HBDModalWindow *containerWindow;
@property(nonatomic, weak) UIWindow *previousKeyWindow;
@property(nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGestureRecognizer;

@property(nonatomic, assign, readwrite, getter=isVisible) BOOL visible;

@property(nonatomic, assign) BOOL appearAnimated;
@property(nonatomic, copy) void (^appearCompletionBlock)(BOOL finished);

@property(nonatomic, assign) BOOL disappearAnimated;
@property(nonatomic, copy) void (^disappearCompletionBlock)(BOOL finished);

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
    self.contentViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    self.maximumContentViewWidth = [UIScreen mainScreen].bounds.size.width - 40;
    [self initDefaultDimmingViewWithoutAddToView];
}

- (void)dealloc {
    self.containerWindow = nil;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    // 屏蔽对childViewController的生命周期函数的自动调用，改为手动控制
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    if (self.dimmingView && !self.dimmingView.superview) {
        [self.view addSubview:self.dimmingView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.dimmingView.frame = self.view.bounds;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    RCTLogInfo(@"modal viewWillAppear");
    // 只有使用showWithAnimated:completion:显示出来的浮层，才需要修改之前就记住的animated的值
    animated = self.appearAnimated;
    
    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:YES animated:animated];
    }

    void (^didShownCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.visible = YES;
        
        if (self.appearCompletionBlock) {
            self.appearCompletionBlock(finished);
            self.appearCompletionBlock = nil;
        }
        
        self.appearAnimated = NO;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    RCTLogInfo(@"modal viewWillDisappear");
    animated = self.disappearAnimated;
    [self.view endEditing:YES];

    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:NO animated:animated];
    }
    
    void (^didHiddenCompletion)(BOOL finished) = ^(BOOL finished) {
        if ([[UIApplication sharedApplication] keyWindow] == self.containerWindow) {
            if (self.previousKeyWindow.hidden) {
                [[UIApplication sharedApplication].delegate.window makeKeyWindow];
            } else {
                [self.previousKeyWindow makeKeyWindow];
            }
        }
        self.containerWindow.hidden = YES;
        self.containerWindow.rootViewController = nil;
        self.previousKeyWindow = nil;
        [self endAppearanceTransition];
    
        [self.contentView removeFromSuperview];
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.visible = NO;
        
        if (self.willDismissBlock) {
            self.willDismissBlock(self);
        }
        
        if (self.disappearCompletionBlock) {
            self.disappearCompletionBlock(YES);
            self.disappearCompletionBlock = nil;
        }
        
        if (self.contentViewController) {
            self.contentViewController.hbd_targetViewController.hbd_popupViewController = nil;
            self.contentViewController.hbd_targetViewController = nil;
            self.contentViewController.hbd_modalViewController = nil;
            self.contentViewController = nil;
        }
        
        self.disappearAnimated = NO;
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

- (void)updateLayout {
    if ([self isViewLoaded]) {
        [self.view setNeedsLayout];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
       
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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
    // __weak __typeof(self)weakSelf = self;
    [self hideWithAnimated:YES completion:^(BOOL finished) {
        // DO something
    }];
}

#pragma mark - ContentView

- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;
    _contentViewController.hbd_modalViewController = self;
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
    // makeKeyAndVisible 导致的 viewWillAppear: 必定 animated 是 NO 的，所以这里用额外的变量保存这个 animated 的值
    self.contentView = self.contentViewController.view;
    self.appearAnimated = animated;
    self.appearCompletionBlock = completion;
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    if (!self.containerWindow) {
        self.containerWindow = [[HBDModalWindow alloc] init];
        self.containerWindow.windowLevel = UIWindowLevelAlert - 4.0;;
        self.containerWindow.backgroundColor = UIColor.clearColor;// 避免横竖屏旋转时出现黑色
    }
    self.containerWindow.rootViewController = self;
    [self.containerWindow makeKeyAndVisible];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.disappearAnimated = animated;
    self.disappearCompletionBlock = completion;
    [self beginAppearanceTransition:NO animated:animated];
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
    HBDModalViewController *modalViewController = [[HBDModalViewController alloc] init];
    modalViewController.contentViewController = vc;
    self.hbd_popupViewController = vc;
    vc.hbd_targetViewController = self;
    [modalViewController showWithAnimated:animated completion:completion];
}

- (void)hbd_hideViewControllerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (self.hbd_popupViewController) {
        [self.hbd_popupViewController.hbd_modalViewController hideWithAnimated:animated completion:completion];
    } else {
        [self.hbd_targetViewController hbd_hideViewControllerAnimated:animated completion:completion];
    }
}

@end


