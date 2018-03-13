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
@property (nonatomic, strong) UIView             *menuDimmingView;          // 侧边栏半透明黑底

@end

@implementation HBDDrawerController

- (instancetype)initWithContentViewController:(UIViewController *)content menuViewController:(UIViewController *)menu {
    if (self = [super init]) {
        _contentViewController = content;
        _menuViewController = menu;
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
    
    UIScreenEdgePanGestureRecognizer *edgePanGestureRecogizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanGestureRecognizer:)];
    edgePanGestureRecogizer.edges = UIRectEdgeLeft;
    edgePanGestureRecogizer.delegate = self;
    [self.view addGestureRecognizer:edgePanGestureRecogizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;
   
}

- (void)setMenuViewController:(UIViewController *)menuViewController {
    _menuViewController = menuViewController;
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
    if (menuOpened) {
        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelStatusBar +1;
    } else {
        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UINavigationController *nav = [super navigationController];
    if (!nav) {
        return [self closestNavigationController:self.contentViewController];
    }
    return nil;
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
        return !self.menuDimmingView;
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
        menu.view.frame = CGRectMake(0, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    } completion:^(BOOL finished) {
       
    }];
}

- (void)addMenuView {
    UIViewController *menu = self.menuViewController;
    float menuWidth = [self menuWidth];
    
    menu.view.frame = CGRectMake(-menuWidth, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    [self addChildViewController:menu];
    
    UIView *dimmingView = [[UIView alloc] init];
    dimmingView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.5];
    dimmingView.frame = self.view.bounds;
    self.menuDimmingView = dimmingView;
    [self.menuDimmingView addSubview:menu.view];
    [self.view insertSubview:self.menuDimmingView aboveSubview:self.contentViewController.view];
    [self addGestureRecognizerToMenuDimmingView];
    [menu didMoveToParentViewController:self];
}

- (void)addGestureRecognizerToMenuDimmingView {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGestureRecognizer.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    
    [self.menuDimmingView addGestureRecognizer:panGestureRecognizer];
    [self.menuDimmingView addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleEdgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat dx = [recognizer translationInView:self.view].x;
    CGFloat width = [self menuWidth];
    dx = MIN(dx, width);
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        [self addMenuView];
        self.menuViewController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
        [UIView animateWithDuration:0.35 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.menuOpened = YES;
        } completion:^(BOOL finished) {
            
        }];
    } else if(UIGestureRecognizerStateChanged == recognizer.state) {
        self.menuViewController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
    } else {
        if ( dx / width < 0.1) {
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
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.menuViewController.view.frame = CGRectMake(dx, 0, width, height);
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (dx / -width > 0.1) {
            [self dismissMenuView];
        } else {
            [self settleMuneView];
        }
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [self dismissMenuView];
}

- (void)settleMuneView {
    CGFloat width = CGRectGetWidth(self.menuViewController.view.frame);
    CGFloat dx = 0 - CGRectGetMinX(self.menuViewController.view.frame);
    CGRect rect = CGRectOffset(self.menuViewController.view.frame, dx, 0);
    CGFloat duration = (dx/width) * 0.2;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuViewController.view.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissMenuView {
    float menuWidth = [self menuWidth];
    CGFloat dx = -menuWidth - CGRectGetMinX(self.menuViewController.view.frame);
    CGRect rect = CGRectOffset(self.menuViewController.view.frame, dx, 0);
    CGFloat duration = ( 1- (dx + menuWidth)/menuWidth ) * 0.2;
    [self.menuViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuViewController.view.frame = rect;
    } completion:^(BOOL finished) {
        [self.menuViewController removeFromParentViewController];
        [self.menuViewController.view removeFromSuperview];
        [UIView animateWithDuration:0.2 animations:^{
            self.menuDimmingView.alpha = 0;
            self.menuOpened = NO;
        } completion:^(BOOL finished) {
            [self.menuDimmingView removeFromSuperview];
            NSArray *gestureRecognizers = self.menuDimmingView.gestureRecognizers;
            for (UIGestureRecognizer *recognizer in gestureRecognizers) {
                [recognizer removeTarget:self action:@selector(handlePanGestureRecognizer:)];
                [recognizer removeTarget:self action:@selector(handleTapGestureRecognizer:)];
            }
            self.menuDimmingView = nil;
        }];
    }];
}

- (float)menuWidth {
    return CGRectGetWidth(self.view.bounds) - 60;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
