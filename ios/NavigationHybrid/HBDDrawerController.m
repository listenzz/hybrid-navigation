//
//  HBDDrawerController.m
//  NavigationHybrid
//
//  Created by Listen on 2018/1/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDDrawerController.h"

@interface HBDDrawerController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, getter=isMenuOpened) BOOL menuOpened;
@property (nonatomic, strong) UIView *menuDimmingView;          // 侧边栏半透明黑底
@property (nonatomic, strong) UIView *menuHolderView;

@end

@implementation HBDDrawerController

- (instancetype)initWithContentViewController:(UIViewController *)content menuViewController:(UIViewController *)menu {
    if (self = [super init]) {
        _contentViewController = content;
        _menuViewController = menu;
        _interactive = YES;
        _minDrawerMargin = 64;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIScreenEdgePanGestureRecognizer *edgePanGestureRecogizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanGestureRecognizer:)];
    edgePanGestureRecogizer.edges = UIRectEdgeLeft;
    edgePanGestureRecogizer.delegate = self;
    [self.view addGestureRecognizer:edgePanGestureRecogizer];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (self.menuOpened) {
            self.menuHolderView.frame = CGRectMake(0, 0, size.width, size.height);
            self.menuDimmingView.frame = self.menuHolderView.bounds;
            self.menuViewController.view.frame = CGRectMake(0, 0, [self menuWidth], size.height);
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self setStatusBarHidden:self.menuOpened];
    }];
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;
}

- (void)setMenuViewController:(UIViewController *)menuViewController {
    _menuViewController = menuViewController;
}

- (void)openMenu {
    if (!self.isMenuOpened) {
        // [self.menuViewController beginAppearanceTransition:YES animated:YES];
       //  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
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
    [self setStatusBarHidden:menuOpened];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.contentViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.contentViewController;
}

- (UINavigationController *)navigationController {
    // menuViewController   通过 self.navigationController 的方式是获取不到 nav 的
    // 需要通过 self.drawerController.navigationController 的方式来获取
    return [self closestNavigationController:self.contentViewController];
}

- (UINavigationController *)closestNavigationController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)vc;
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        return [self closestNavigationController:tab.selectedViewController];
    }
    return nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return  self.interactive && !self.menuDimmingView;
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        return [pan velocityInView:self.menuDimmingView].x < 0;
    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint location = [gestureRecognizer locationInView:self.menuViewController.view];
        return  !CGRectContainsPoint(self.menuViewController.view.frame, location);
    }
    return NO;
}

- (void)presentMenuView {
    [self addMenuView];
    
    UIViewController *menu = self.menuViewController;
    float menuWidth = [self menuWidth];
    
    [UIView animateWithDuration:0.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menuOpened = YES;
        self.menuDimmingView.alpha = 0.5;
        menu.view.frame = CGRectMake(0, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    } completion:^(BOOL finished) {
       
    }];
}

- (void)addMenuView {
    UIViewController *menu = self.menuViewController;
    float menuWidth = [self menuWidth];
    
    menu.view.frame = CGRectMake(-menuWidth, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    [self addChildViewController:menu];
    
    UIView *menuHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.menuHolderView = menuHolderView;
    UIView *dimmingView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmingView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:1.0];
    dimmingView.alpha = 0;
    self.menuDimmingView = dimmingView;
    
    [self.view insertSubview:menuHolderView aboveSubview:self.contentViewController.view];
    [menuHolderView addSubview:dimmingView];
    [self addGestureRecognizerToMenuHolderView];
    [menuHolderView addSubview:menu.view];
    [menu didMoveToParentViewController:self];
}

- (void)dismissMenuView {
    float menuWidth = [self menuWidth];
    CGFloat dx = -menuWidth - CGRectGetMinX(self.menuViewController.view.frame);
    CGRect rect = CGRectOffset(self.menuViewController.view.frame, dx, 0);
    CGFloat duration = ( 1- (dx + menuWidth)/menuWidth ) * 0.2;
    [self.menuViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuViewController.view.frame = rect;
        self.menuDimmingView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.menuViewController removeFromParentViewController];
        [self.menuViewController.view removeFromSuperview];
        [self.menuDimmingView removeFromSuperview];
        self.menuDimmingView = nil;
        [self.menuHolderView removeFromSuperview];
        self.menuHolderView = nil;
        self.menuOpened = NO;
    }];
}

- (void)settleMuneView {
    CGFloat width = CGRectGetWidth(self.menuViewController.view.frame);
    CGFloat dx = 0 - CGRectGetMinX(self.menuViewController.view.frame);
    CGRect rect = CGRectOffset(self.menuViewController.view.frame, dx, 0);
    CGFloat duration = (dx/width) * 0.2;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuViewController.view.frame = rect;
        self.menuDimmingView.alpha = 0.5;
    } completion:^(BOOL finished) {
        
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
        self.menuViewController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
        self.menuDimmingView.alpha = dx * 0.5 / width;
        self.menuOpened = YES;
    } else if(UIGestureRecognizerStateChanged == recognizer.state) {
        self.menuViewController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
        self.menuDimmingView.alpha = dx * 0.5 / width;
    } else {
        if ( dx / width < 0.2) {
            [self dismissMenuView];
        } else {
            [self settleMuneView];
        }
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGFloat dx = [recognizer translationInView:self.menuDimmingView].x;
    CGFloat width = CGRectGetWidth(self.menuViewController.view.bounds);
    CGFloat height = CGRectGetHeight(self.menuViewController.view.bounds);
    dx = MIN(0, MAX(-width, dx));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.menuViewController.view.frame = CGRectMake(dx, 0, width, height);
        self.menuDimmingView.alpha = (dx + width) * 0.5 / width;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.menuViewController.view.frame = CGRectMake(dx, 0, width, height);
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

- (float)menuWidth {
    CGFloat maxWidth = CGRectGetWidth(self.view.bounds);
    CGFloat margin1 = self.minDrawerMargin;
    if (margin1 > maxWidth) {
        margin1 = maxWidth;
    } else if (margin1 < 0) {
        margin1 = 0;
    }
    if (self.maxDrawerWidth <=0 || self.maxDrawerWidth > maxWidth) {
        self.maxDrawerWidth = maxWidth;
    }
    CGFloat margin2 = maxWidth - self.maxDrawerWidth;
    CGFloat margin = MAX(margin1, margin2);
    return maxWidth - margin;
}

- (void)setStatusBarHidden:(BOOL)hidden {
    UIWindow *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    if (!statusBar) {
        return;
    }
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    [UIView animateWithDuration:0.4 animations:^{
        statusBar.transform = hidden ? CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -statusBarHeight) : CGAffineTransformIdentity;
    }];
}

@end
