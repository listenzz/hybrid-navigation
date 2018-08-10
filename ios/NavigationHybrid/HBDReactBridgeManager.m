//
//  HBDReactBridgeManager.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDReactBridgeManager.h"
#import <React/RCTLog.h>
#import "HBDUtils.h"
#import "HBDReactViewController.h"
#import "HBDNavigationController.h"
#import "HBDTabBarController.h"
#import "HBDDrawerController.h"
#import "HBDScreenNavigator.h"
#import "HBDStackNavigator.h"
#import "HBDTabNavigator.h"
#import "HBDDrawerNavigator.h"

NSString * const ReactModuleRegistryDidCompletedNotification = @"ReactModuleRegistryDidCompletedNotification";
const NSInteger ResultOK = -1;
const NSInteger ResultCancel = 0;

@interface HBDReactBridgeManager() <RCTBridgeDelegate>

@property(nonatomic, copy) NSURL *jsCodeLocation;
@property(nonatomic, strong) NSMutableDictionary *nativeModules;
@property(nonatomic, strong) NSMutableDictionary *reactModules;
@property(nonatomic, assign) BOOL isReactModuleInRegistry;
@property(nonatomic, copy) NSMutableArray *navigators;

@end

@implementation HBDReactBridgeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HBDReactBridgeManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager registerNavigator:[HBDScreenNavigator new]];
        [manager registerNavigator:[HBDStackNavigator new]];
        [manager registerNavigator:[HBDTabNavigator new]];
        [manager registerNavigator:[HBDDrawerNavigator new]];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _nativeModules = [[NSMutableDictionary alloc] init];
        _reactModules = [[NSMutableDictionary alloc] init];
        _isReactModuleInRegistry = YES;
        _navigators = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReload) name:RCTBridgeWillReloadNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
}

- (void)handleReload {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    application.keyWindow.rootViewController = [[UIViewController alloc] init];
    application.keyWindow.rootViewController.view.backgroundColor = UIColor.whiteColor;
}

- (void)installWithBundleURL:jsCodeLocation launchOptions:(NSDictionary *)launchOptions {
    _jsCodeLocation = jsCodeLocation;
    
    _bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
}

- (void)registerNativeModule:(NSString *)moduleName forController:(Class)clazz {
    [_nativeModules setObject:clazz forKey:moduleName];
}

- (BOOL)hasNativeModule:(NSString *)moduleName {
    return [_nativeModules objectForKey:moduleName] != nil;
}

- (Class)nativeModuleClassFromName:(NSString *)moduleName {
    return [_nativeModules objectForKey:moduleName];
}

- (void)registerReactModule:(NSString *)moduleName options:(NSDictionary *)options {
    NSCAssert(self.isReactModuleInRegistry, @"非法操作，你应该先调用 `startRegisterReactModule`");
    [_reactModules setObject:options forKey:moduleName];
}

- (NSDictionary *)reactModuleOptionsForKey:(NSString *)moduleName {
    return [_reactModules objectForKey:moduleName];
}

- (BOOL)hasReactModuleForName:(NSString *)moduleName {
    return [_reactModules objectForKey:moduleName] != nil;
}

- (BOOL)isReactModuleInRegistry {
    return _isReactModuleInRegistry;
}

- (void)startRegisterReactModule {
    _isReactModuleInRegistry = YES;
    [_reactModules removeAllObjects];
}

- (void)endRegisterReactModule {
    _isReactModuleInRegistry = NO;
    if (self.delegate != nil) {
        [self.delegate reactModuleRegistryDidCompleted:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ReactModuleRegistryDidCompletedNotification object:nil];
}

- (UIViewController *)controllerWithLayout:(NSDictionary *)layout {
    UIViewController *vc;
    for (id<HBDNavigator> navigator in self.navigators) {
        if ((vc = [navigator createViewControllerWithLayout:layout])) {
            break;
        }
    }
    return vc;
}

- (HBDViewController *)controllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    HBDViewController *vc = nil;
    
    while ([self isReactModuleInRegistry]) {
        NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop mainRunLoop] runUntilDate:later];
    }
    
    if (!props) {
        props = @{};
    }
    
    if (!options) {
        options = @{};
    }
    
    if ([self hasReactModuleForName:moduleName]) {
        NSDictionary *staticOptions = [[HBDReactBridgeManager sharedInstance] reactModuleOptionsForKey:moduleName];
        options = [HBDUtils mergeItem:options withTarget:staticOptions];
        vc = [[HBDReactViewController alloc] initWithModuleName:moduleName props:props options:options];
    } else {
        Class clazz =  [self nativeModuleClassFromName:moduleName];
        NSCAssert([self hasNativeModule:moduleName], @"找不到名为 %@ 的模块，你是否忘了注册？", moduleName);
        vc = [[clazz alloc] initWithModuleName:moduleName props:props options:options];
    }
    
    NSDictionary *tabItem = options[@"tabItem"];
    if (tabItem) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        tabBarItem.title = tabItem[@"title"];
        
        NSDictionary *selectedIcon = tabItem[@"selectedIcon"];
        if (selectedIcon) {
            tabBarItem.selectedImage = [[HBDUtils UIImage:selectedIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tabBarItem.image = [[HBDUtils UIImage:tabItem[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            tabBarItem.image = [HBDUtils UIImage:tabItem[@"icon"]];
        }
        
        vc.tabBarItem = tabBarItem;
    }
    
    return vc;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    UIWindow *keyWindow = RCTKeyWindow();
    if (keyWindow.rootViewController.presentedViewController) {
        [keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self performSelector:@selector(performSetRootViewController:) withObject:rootViewController afterDelay:0];
        }];
    } else {
        [self performSetRootViewController:rootViewController];
    }
}

- (void)performSetRootViewController:(UIViewController *)rootViewController {
    UIWindow *keyWindow = RCTKeyWindow();
    keyWindow.rootViewController = rootViewController;
}

- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc {
    HBDViewController *hbdVC = nil;
    for (id<HBDNavigator> navigator in self.navigators) {
        hbdVC = [navigator primaryChildViewControllerInController:vc];
        if (hbdVC) {
            break;
        }
    }
    return hbdVC;
}

- (void)routeGraphWithController:(UIViewController *)controller container:(NSMutableArray *)container {
    for (id<HBDNavigator> navigator in self.navigators) {
        if ([navigator buildRouteGraphWithController:controller graph:container]) {
            return;
        }
    }
}

- (void)handleNavigationWithViewController:(HBDViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras {
    for (id<HBDNavigator> navigator in self.navigators) {
        NSArray<NSString *> *supportActions = navigator.supportActions;
        if ([supportActions containsObject:action]) {
            [navigator handleNavigationWithViewController:vc action:action extras:extras];
            break;
        }
    }
}

- (void)registerNavigator:(id<HBDNavigator>)navigator {
    [self.navigators insertObject:navigator atIndex:0];
}

#pragma mark - bridge delegate

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
    return _jsCodeLocation;
}

@end
