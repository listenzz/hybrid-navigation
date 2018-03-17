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

NSString * const ReactModuleRegistryDidCompletedNotification = @"ReactModuleRegistryDidCompletedNotification";

@interface HBDReactBridgeManager() <RCTBridgeDelegate>

@property(nonatomic, copy) NSURL *jsCodeLocation;
@property(nonatomic, strong) NSMutableDictionary *nativeModules;
@property(nonatomic, strong) NSMutableDictionary *reactModules;
@property(nonatomic, assign) BOOL isReactModuleInRegistry;

@end

@implementation HBDReactBridgeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HBDReactBridgeManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _nativeModules = [[NSMutableDictionary alloc] init];
        _reactModules = [[NSMutableDictionary alloc] init];
        _isReactModuleInRegistry = YES;
    }
    return self;
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
    NSDictionary *screen = [layout objectForKey:@"screen"];
    if (screen) {
        NSString *moduleName = [screen objectForKey:@"moduleName"];
        NSDictionary *props = [screen objectForKey:@"props"];
        NSDictionary *options = [screen objectForKey:@"options"];
        return [self controllerWithModuleName:moduleName props:props options:options];
    }
    
    NSDictionary *stack = [layout objectForKey:@"stack"];
    if (stack) {
        UIViewController *root = [self controllerWithLayout:stack];
        if (root) {
            return [[HBDNavigationController alloc] initWithRootViewController:root];
        }
    }
    
    NSArray *tabs = [layout objectForKey:@"tabs"];
    if (tabs) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSDictionary *tab in tabs) {
            UIViewController *vc = [self controllerWithLayout:tab];
            if (vc) {
                [controllers addObject:vc];
            }
        }
        
        if (controllers.count > 0) {
            HBDTabBarController *tabBarController = [[HBDTabBarController alloc] init];
            [tabBarController setViewControllers:controllers];
            return tabBarController;
        }
    }
    
    NSArray *drawer = [layout objectForKey:@"drawer"];
    if (drawer && drawer.count == 2) {
        NSDictionary *content = [drawer objectAtIndex:0];
        NSDictionary *menu = [drawer objectAtIndex:1];
        
        UIViewController *contentController = [self controllerWithLayout:content];
        UIViewController *menuController = [self controllerWithLayout:menu];
        
        if (contentController && menuController) {
            HBDDrawerController *drawerController = [[HBDDrawerController alloc] initWithContentViewController:contentController menuViewController:menuController];
            NSDictionary *menuOptions = [menu objectForKey:@"options"];
            if (menuOptions) {
                NSNumber *maxDrawerWidth = [menuOptions objectForKey:@"maxDrawerWidth"];
                NSNumber *minDrawerMargin = [menuOptions objectForKey:@"minDrawerMargin"];
                if (maxDrawerWidth) {
                    [drawerController setMaxDrawerWidth:[maxDrawerWidth floatValue]];
                }
                
                if (minDrawerMargin) {
                    [drawerController setMinDrawerMargin:[minDrawerMargin floatValue]];
                }
            }
            return drawerController;
        }
    }
    
    return nil;
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

#pragma mark - bridge delegate

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
    return _jsCodeLocation;
}

@end
