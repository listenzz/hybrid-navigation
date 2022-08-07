#import "HBDTabBarController.h"

#import "HBDReactViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDUtils.h"
#import "HBDEventEmitter.h"
#import "HBDReactTabBar.h"
#import "HBDFadeAnimation.h"

#import <React/RCTRootView.h>
#import <React/RCTRootViewDelegate.h>
#import <React/RCTLog.h>


@interface HBDTabBarController () <UITabBarControllerDelegate, RCTRootViewDelegate>

@property(nonatomic, strong) RCTRootView *rootView;
@property(nonatomic, copy) NSDictionary *tabBarOptions;
@property(nonatomic, assign) BOOL hasCustomTabBar;

@end

@implementation HBDTabBarController

- (instancetype)initWithTabBarOptions:(NSDictionary *)options {
    self.tabBarOptions = options;
    self.hasCustomTabBar = YES;
    return [super init];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    self.delegate = self;
    self.intercepted = YES;
    if (self.hasCustomTabBar) {
        [self setValue:[[HBDReactTabBar alloc] init] forKey:@"tabBar"];
        [self customTabBar];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.hasCustomTabBar) {
        [self removeTabBarAboriginal];
        [self.tabBar bringSubviewToFront:self.rootView];
    }
}

- (void)customTabBar {
    NSString *moduleName = self.tabBarOptions[@"tabBarModuleName"];
    NSMutableDictionary *props = [[self props] mutableCopy];
    props[@"selectedIndex"] = self.tabBarOptions[@"selectedIndex"];
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[HBDReactBridgeManager get].bridge moduleName:moduleName initialProperties:props];
    rootView.backgroundColor = UIColor.clearColor;

    BOOL sizeIndeterminate = [self.tabBarOptions[@"sizeIndeterminate"] boolValue];
    if (sizeIndeterminate) {
        rootView.delegate = self;
        rootView.passThroughTouches = YES;
        rootView.sizeFlexibility = RCTRootViewSizeFlexibilityWidthAndHeight;
    } else {
        rootView.frame = CGRectMake(0, 1, CGRectGetWidth(self.tabBar.bounds), 48);
    }
    [self.tabBar addSubview:rootView];
    self.rootView = rootView;
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    CGFloat width = rootView.intrinsicContentSize.width;
    CGFloat height = rootView.intrinsicContentSize.height;
    CGRect frame = CGRectMake(0, 48 - height, width, height);
    self.rootView.frame = frame;
}

- (NSDictionary *)props {
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    NSDictionary *options = self.tabBarOptions;
    props[@"sceneId"] = self.sceneId;
    props[@"tabs"] = options[@"tabs"];
    props[@"selectedIndex"] = @(self.selectedIndex);
    props[@"badgeColor"] = options[@"badgeColor"];

    NSString *tabBarItemColor = options[@"tabBarItemColor"];
    NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
    if (tabBarItemColor) {
        props[@"itemColor"] = tabBarItemColor;
        props[@"unselectedItemColor"] = RCTNullIfNil(tabBarUnselectedItemColor);
    }
    return props;
}

- (void)removeTabBarAboriginal {
    NSUInteger count = self.tabBar.subviews.count;
    for (NSUInteger i = count; i > 0; i--) {
        NSUInteger index = i - 1;
        UIView *view = self.tabBar.subviews[index];
        NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([viewName isEqualToString:@"UITabBarButton"]) {
            [view removeFromSuperview];
        }
    }
}

- (void)setTabItem:(NSArray<NSDictionary *> *)options {
    for (NSDictionary *option in options) {
        NSUInteger index = (NSUInteger) (option[@"index"] ? [option[@"index"] integerValue] : 0);
        if (self.hasCustomTabBar) {
            [self updateCustomTabItem:option atIndex:index];
        } else {
            UIViewController *tab = self.viewControllers[index];
            [tab hbd_updateTabBarItem:option];
        }
    }

    if (self.hasCustomTabBar) {
        self.rootView.appProperties = [self props];
    }
}

- (NSMutableDictionary *)tabAtIndex:(NSUInteger)index {
    NSMutableDictionary *options = [self.tabBarOptions mutableCopy];
    NSMutableArray *tabs = [options[@"tabs"] mutableCopy];
    options[@"tabs"] = tabs;
    NSMutableDictionary *tab = [tabs[index] mutableCopy];
    tabs[index] = tab;
    self.tabBarOptions = options;
    return tab;
}

- (void)updateCustomTabItem:(NSDictionary *)option atIndex:(NSUInteger)index {
    NSMutableDictionary *tab = [self tabAtIndex:index];

    // title
    NSString *title = option[@"title"];
    if (title != nil) {
        tab[@"title"] = title;
    }

    // icon title
    NSDictionary *icon = option[@"icon"];
    if (icon != nil) {
        NSDictionary *selected = icon[@"selected"];
        tab[@"icon"] = [HBDUtils iconUriFromUri:selected[@"uri"]];

        NSDictionary *unselected = icon[@"unselected"];
        if (unselected != nil) {
            tab[@"unselectedIcon"] = RCTNullIfNil([HBDUtils iconUriFromUri:unselected[@"uri"]]);
        }
    }

    // badge
    NSDictionary *badge = option[@"badge"];
    if (badge != nil) {
        BOOL hidden = badge[@"hidden"] ? [badge[@"hidden"] boolValue] : YES;
        NSString *text = hidden ? nil : (badge[@"text"] ? badge[@"text"] : nil);
        BOOL dot = hidden ? NO : (badge[@"dot"] ? [badge[@"dot"] boolValue] : NO);
        tab[@"dot"] = @(dot);
        tab[@"badgeText"] = RCTNullIfNil(text);
    }
}

- (void)updateTabBar:(NSDictionary *)options {
    UITabBar *tabBar = self.tabBar;
    NSString *tabBarColor = options[@"tabBarColor"];
    if (tabBarColor) {
        if (@available(iOS 15.0, *)) {
            [tabBar standardAppearance].backgroundImage = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]];
            [tabBar scrollEdgeAppearance].backgroundImage = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]];
        } else {
            [tabBar setBackgroundImage:[HBDUtils imageWithColor:[HBDUtils colorWithHexString:tabBarColor]]];
        }
    }

    NSDictionary *tabBarShadowImage = options[@"tabBarShadowImage"];
    if (RCTNilIfNull(tabBarShadowImage)) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = tabBarShadowImage[@"image"];
        NSString *color = tabBarShadowImage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        tabBar.shadowImage = image;
    }

    NSString *tabBarItemColor = options[@"tabBarItemColor"];
    NSString *tabBarUnselectedItemColor = options[@"tabBarUnselectedItemColor"];
    if (tabBarItemColor) {
        if (self.hasCustomTabBar) {
            NSMutableDictionary *options = [self.tabBarOptions mutableCopy];
            options[@"tabBarItemColor"] = tabBarItemColor;
            options[@"tabBarUnselectedItemColor"] = RCTNullIfNil(tabBarUnselectedItemColor);
            self.tabBarOptions = options;
            self.rootView.appProperties = [self props];
        } else {
            tabBar.tintColor = [HBDUtils colorWithHexString:tabBarItemColor];
            if (tabBarUnselectedItemColor) {
                tabBar.unselectedItemTintColor = [HBDUtils colorWithHexString:tabBarUnselectedItemColor];
            }
        }
    }
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    if (self.hasCustomTabBar) {
        [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                KEY_ON: ON_COMPONENT_RESULT,
                KEY_REQUEST_CODE: @(requestCode),
                KEY_RESULT_CODE: @(resultCode),
                KEY_RESULT_DATA: RCTNullIfNil(data),
                KEY_SCENE_ID: self.sceneId,
        }];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedViewController:self.viewControllers[selectedIndex]];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    [super setSelectedViewController:selectedViewController];

    if (self.hasCustomTabBar && self.rootView) {
        NSMutableDictionary *props = [[self props] mutableCopy];
        props[@"selectedIndex"] = @(index);
        self.rootView.appProperties = props;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([[HBDReactBridgeManager get] hasRootLayout] && self.intercepted) {
        long from = self.selectedIndex;
        long to = [self.childViewControllers indexOfObject:viewController];

        [HBDEventEmitter sendEvent:EVENT_SWITCH_TAB data:@{
                KEY_SCENE_ID: self.sceneId,
                KEY_INDEX: [NSString stringWithFormat:@"%ld-%ld", from, to],
        }];
        return NO;
    }
    return YES;
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    if (toVC.viewLoaded) {
        return nil;
    }
    
    return [[HBDFadeAnimation alloc] init];
}

@end
