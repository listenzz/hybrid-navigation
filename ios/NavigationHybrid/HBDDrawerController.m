//
//  HBDDrawerController.m
//
//  Created by Listen on 2018/1/25.
//

#define IS_PORTRAIT UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)
#define IS_IPHONE    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_X    (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) == 812.0)

#import "HBDDrawerController.h"

@interface HBDDrawerController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UIViewController *contentController;
@property (nonatomic, strong, readwrite) UIViewController *menuController;

@property (nonatomic, assign, getter=isMenuOpened) BOOL menuOpened;
@property (nonatomic, strong) UIView             *menuDimmingView;          // 侧边栏半透明黑底
@property (nonatomic, strong) UIImageView        *statusBarView;

@end

@implementation HBDDrawerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addChildViewController:self.contentController];
    self.contentController.view.frame = self.view.bounds;
    [self.view addSubview:self.contentController.view];
    [self.contentController didMoveToParentViewController:self];
    
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
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!self.statusBarView && self.navigationController) {
        self.contentController.view.frame = CGRectMake(0, [self statusBarHeight], CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - [self statusBarHeight]);
        
        UIImageView *statusView = [[UIImageView alloc] init];
        statusView.image = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        statusView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), [self statusBarHeight]);
        [self.view insertSubview:statusView aboveSubview:self.contentController.view];
        self.statusBarView = statusView;
    }
}

- (BOOL)prefersStatusBarHidden {
    return _menuOpened;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.contentController;
}

- (UINavigationController *)navigationController {
    UINavigationController *nav = [super navigationController];
    if (!nav) {
        return [self closetNavigationController:self.contentController];
    }
    return nil;
}

- (UINavigationController *)closetNavigationController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)vc;
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        return [self closetNavigationController:tab.selectedViewController];
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
        CGPoint location = [gestureRecognizer locationInView:self.menuController.view];
        return  !CGRectContainsPoint(self.menuController.view.frame, location);
    }
    return NO;
}

- (void)presentMenuView {
    [self addMenuView];
    
    UIViewController *menu = self.menuController;
    float menuWidth = [self menuWidth];
    
    [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menuOpened = YES;
        menu.view.frame = CGRectMake(0, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    } completion:^(BOOL finished) {
        [menu didMoveToParentViewController:self];
    }];
}

- (void)addMenuView {
    UIViewController *menu = self.menuController;
    float menuWidth = [self menuWidth];
    
    menu.view.frame = CGRectMake(-menuWidth, 0, menuWidth, CGRectGetHeight(self.view.bounds));
    [self addChildViewController:menu];
    
    UIView *dimmingView = [[UIView alloc] init];
    dimmingView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.5];
    dimmingView.frame = self.view.bounds;
    self.menuDimmingView = dimmingView;
    [self.menuDimmingView addSubview:menu.view];
    
    UIView *aboveView;
    if (self.navigationController) {
        aboveView = self.statusBarView;
    } else {
        aboveView = self.contentController.view;
    }
    
    [self.view insertSubview:self.menuDimmingView aboveSubview:aboveView];
    [self addGestureRecognizerToMenuDimmingView];
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
        self.menuController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
    } else if(UIGestureRecognizerStateChanged == recognizer.state) {
        self.menuController.view.frame = CGRectMake(-width + dx, 0, width, CGRectGetHeight(self.view.bounds));
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
    CGFloat width = CGRectGetWidth(self.menuController.view.bounds);
    CGFloat height = CGRectGetHeight(self.menuController.view.bounds);
    dx = MIN(0, MAX(-width, dx));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.menuController.view.frame = CGRectMake(dx, 0, width, height);
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.menuController.view.frame = CGRectMake(dx, 0, width, height);
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
    CGFloat width = CGRectGetWidth(self.menuController.view.frame);
    CGFloat dx = 0 - CGRectGetMinX(self.menuController.view.frame);
    CGRect rect = CGRectOffset(self.menuController.view.frame, dx, 0);
    CGFloat duration = (dx/width) * 0.3;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.menuController.view.frame = rect;
        self.menuOpened = YES;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissMenuView {
    float menuWidth = [self menuWidth];
    CGFloat dx = -menuWidth - CGRectGetMinX(self.menuController.view.frame);
    CGRect rect = CGRectOffset(self.menuController.view.frame, dx, 0);
    CGFloat duration = ( 1- (dx + menuWidth)/menuWidth ) * 0.25;
    [self.menuController willMoveToParentViewController:nil];
    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuController.view.frame = rect;
    } completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self.menuController.view removeFromSuperview];
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

- (float)statusBarHeight {
    if (IS_PORTRAIT) {
        if (IS_IPHONE_X) {
            return 44;
        } else {
            return 20;
        }
    } else {
        if (IS_IPHONE_X) {
            return 0;
        } else {
            return 20;
        }
    }
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
