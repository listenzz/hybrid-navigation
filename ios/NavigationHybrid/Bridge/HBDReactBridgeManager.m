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
#import "HBDModalViewController.h"

NSString * const ReactModuleRegistryDidCompletedNotification = @"ReactModuleRegistryDidCompletedNotification";
const NSInteger ResultOK = -1;
const NSInteger ResultCancel = 0;

@interface HBDReactBridgeManager() <RCTBridgeDelegate>

@property(nonatomic, copy) NSURL *jsCodeLocation;
@property(nonatomic, strong) NSMutableDictionary *nativeModules;
@property(nonatomic, strong) NSMutableDictionary *reactModules;
@property(nonatomic, assign, readwrite, getter=isReactModuleRegisterCompleted) BOOL reactModuleRegisterCompleted;
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
        _reactModuleRegisterCompleted = NO;
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
    NSCAssert(!self.reactModuleRegisterCompleted, @"非法操作，你应该先调用 `startRegisterReactModule`");
    [_reactModules setObject:options forKey:moduleName];
}

- (NSDictionary *)reactModuleOptionsForKey:(NSString *)moduleName {
    return [_reactModules objectForKey:moduleName];
}

- (BOOL)hasReactModuleForName:(NSString *)moduleName {
    return [_reactModules objectForKey:moduleName] != nil;
}

- (void)startRegisterReactModule {
    _reactModuleRegisterCompleted = NO;
    [_reactModules removeAllObjects];
}

- (void)endRegisterReactModule {
    _reactModuleRegisterCompleted = YES;
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
    
    while (!self.isReactModuleRegisterCompleted) {
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

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    HBDViewController *vc = nil;
    for (UIWindow *window in application.windows) {
        vc = [self controllerForSceneId:sceneId inController:window.rootViewController];
        if (vc) {
            break;
        }
    }
    return vc;
}

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId inController:(UIViewController *)controller {
    HBDViewController *target;
    
    if ([controller isKindOfClass:[HBDViewController class]]) {
        HBDViewController *vc = (HBDViewController *)controller;
        if ([vc.sceneId isEqualToString:sceneId]) {
            target = vc;
        }
    }
    
    if (!target && [controller isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)controller;
        target = [self controllerForSceneId:sceneId inController:modal.contentViewController];
    }
    
    if (!target) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            target = [self controllerForSceneId:sceneId inController:presentedController];
        }
    }
    
    if (!target && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            target = [self controllerForSceneId:sceneId inController:child];
            if (target) {
                break;
            }
        }
    }
    return target;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    UIWindow *keyWindow = RCTKeyWindow();
    if (keyWindow.rootViewController.presentedViewController && !keyWindow.rootViewController.presentedViewController.isBeingDismissed) {
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
