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
#import "HBDModalViewController.h"
#import "HBDViewController.h"
#import "HBDNavigatorRegistry.h"


#import "HBDEventEmitter.h"

NSString * const ReactModuleRegistryDidCompletedNotification = @"ReactModuleRegistryDidCompletedNotification";
const NSInteger ResultOK = -1;
const NSInteger ResultCancel = 0;

@interface HBDReactBridgeManager() <RCTBridgeDelegate>

@property(nonatomic, copy) NSURL *jsCodeLocation;
@property(nonatomic, strong) NSMutableDictionary *nativeModules;
@property(nonatomic, strong) NSMutableDictionary *reactModules;
@property(nonatomic, assign, readwrite, getter=isReactModuleRegisterCompleted) BOOL reactModuleRegisterCompleted;
@property(nonatomic, strong) HBDNavigatorRegistry *navigatorRegistry;

@end

@implementation HBDReactBridgeManager

+ (instancetype)get {
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
        _reactModuleRegisterCompleted = NO;
        _viewHierarchyReady = NO;
        _navigatorRegistry = [[HBDNavigatorRegistry alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReload) name:RCTBridgeWillReloadNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
}

- (UIWindow *)mainWindow {
    UIWindow *mainWindow = RCTSharedApplication().delegate.window;
    if (!mainWindow) {
        mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        mainWindow.backgroundColor = UIColor.whiteColor;
        RCTSharedApplication().delegate.window = mainWindow;
    }
    return mainWindow;
}

- (void)handleReload {
    self.viewHierarchyReady = NO;
    self.reactModuleRegisterCompleted = NO;
    
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        UIViewController *controller = window.rootViewController;
        if ([controller isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)controller;
            [modal.contentViewController hbd_hideViewControllerAnimated:NO completion:nil];
        }
    }
    
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *presentedViewController = mainWindow.rootViewController.presentedViewController;
    if (presentedViewController && !presentedViewController.isBeingDismissed) {
        [mainWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self setLoadingViewController];
        }];
    } else {
        [self setLoadingViewController];
    }
}

- (void)setLoadingViewController {
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = UIColor.whiteColor;
    mainWindow.rootViewController = vc;
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
        [self.delegate reactModuleRegisterDidCompleted:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ReactModuleRegistryDidCompletedNotification object:nil];
}

- (UIViewController *)controllerWithLayout:(NSDictionary *)layout {
    if (!self.isReactModuleRegisterCompleted) {
        return nil;
    }
    
    NSArray<NSString *> *layouts = [self.navigatorRegistry allLayouts];
    id<HBDNavigator> navigator = nil;
    for (NSString *name in layouts) {
        if ([[layout allKeys] containsObject:name]) {
            navigator = [self.navigatorRegistry navigatorForLayout:name];
            break;
        }
    }
    
    if (navigator) {
        return [navigator createViewControllerWithLayout:layout];
    } else {
        RCTLogError(@"找不到可以处理 %@ 的 navigator，你是否忘了注册？", layout);
        return nil;
    }
}

- (HBDViewController *)controllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    HBDViewController *vc = nil;
    
    if (!self.isReactModuleRegisterCompleted) {
        @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"react module has not register completed." userInfo:@{}];
    }
    
    if (!props) {
        props = @{};
    }
    
    if (!options) {
        options = @{};
    }
    
    if ([self hasReactModuleForName:moduleName]) {
        NSDictionary *staticOptions = [[HBDReactBridgeManager get] reactModuleOptionsForKey:moduleName];
        options = [HBDUtils mergeItem:options withTarget:staticOptions];
        vc = [[HBDReactViewController alloc] initWithModuleName:moduleName props:props options:options];
    } else {
        Class clazz =  [self nativeModuleClassFromName:moduleName];
        NSCAssert([self hasNativeModule:moduleName], @"can't find module named with %@ , do you forget to register？", moduleName);
        vc = [[clazz alloc] initWithModuleName:moduleName props:props options:options];
    }
    return vc;
}

- (UIViewController *)controllerForSceneId:(NSString *)sceneId {
    if (!self.viewHierarchyReady) {
        return nil;
    }
    
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *vc = nil;
    for (UIWindow *window in application.windows) {
        if ([window isKindOfClass:[HBDModalWindow class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)window.rootViewController;
            if (!modal || modal.isBeingHidden) {
                continue;
            }
        }
        
        vc = [self controllerForSceneId:sceneId withController:window.rootViewController];
        
        if (vc) {
            break;
        }
    }
    return vc;
}

- (UIViewController *)controllerForSceneId:(NSString *)sceneId withController:(UIViewController *)controller {
    UIViewController *target;
    
    if ([controller.sceneId isEqualToString:sceneId]) {
        target = controller;
    }
    
    if (!target && [controller isKindOfClass:[HBDModalViewController class]]) {
        HBDModalViewController *modal = (HBDModalViewController *)controller;
        target = [self controllerForSceneId:sceneId withController:modal.contentViewController];
    }
    
    if (!target) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            target = [self controllerForSceneId:sceneId withController:presentedController];
        }
    }
    
    if (!target && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            target = [self controllerForSceneId:sceneId withController:child];
            if (target) {
                break;
            }
        }
    }
    return target;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [self setRootViewController:rootViewController withTag:@(0)];
}

- (void)setRootViewController:(UIViewController *)rootViewController withTag:(NSNumber *)tag {
    [HBDEventEmitter sendEvent:EVENT_WILL_SET_ROOT data:@{}];
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        UIViewController *controller = window.rootViewController;
        if ([controller isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)controller;
            [modal.contentViewController hbd_hideViewControllerAnimated:NO completion:nil];
        }
    }

    UIWindow *mainWindow = [self mainWindow];
    UIViewController *presentedViewController = mainWindow.rootViewController.presentedViewController;
    if (presentedViewController && !presentedViewController.isBeingDismissed) {
        [mainWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self performSetRootViewController:rootViewController withTag:tag animated:NO];
        }];
    } else {
        [self performSetRootViewController:rootViewController withTag:tag animated:YES];
    }
}

- (void)performSetRootViewController:(UIViewController *)rootViewController withTag:(NSNumber *)tag animated:(BOOL)animated {
    UIWindow *mainWindow = [self mainWindow];
    if (animated) {
        [UIView transitionWithView:mainWindow duration:0.15f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            BOOL oldState = [UIView areAnimationsEnabled];
            [UIView setAnimationsEnabled:NO];
            mainWindow.rootViewController = rootViewController;
            mainWindow.windowLevel = UIWindowLevelNormal;
            if (!mainWindow.isKeyWindow) {
                [mainWindow makeKeyAndVisible];
            }
            [UIView setAnimationsEnabled:oldState];
            self.viewHierarchyReady = YES;
        } completion:^(BOOL finished) {
            [HBDEventEmitter sendEvent:EVENT_DID_SET_ROOT data:@{ @"tag": tag }];
        }];
    } else {
        mainWindow.rootViewController = rootViewController;
        mainWindow.windowLevel = UIWindowLevelNormal;
        if (!mainWindow.isKeyWindow) {
            [mainWindow makeKeyAndVisible];
        }
        self.viewHierarchyReady = YES;
        [HBDEventEmitter sendEvent:EVENT_DID_SET_ROOT data:@{ @"tag": tag }];
    }
}

- (HBDViewController *)primaryViewController {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        if ([window isKindOfClass:[HBDModalWindow class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)window.rootViewController;
            if (modal && !modal.isBeingHidden) {
                return [self primaryViewControllerWithViewController:modal.contentViewController];
            }
        }
    }
    
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *controller = mainWindow.rootViewController;
    while (controller != nil) {
        UIViewController *presentedController = controller.presentedViewController;
        if (!presentedController) {
            break;
        }
        
        if ([presentedController isBeingDismissed]) {
            break;
        }
        
        if ([presentedController isKindOfClass:[UIAlertController class]]) {
            break;
        }
        controller = presentedController;
    }
    return [self primaryViewControllerWithViewController:controller];
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    HBDViewController *hbdVC = nil;
    for (id<HBDNavigator> navigator in [self.navigatorRegistry allNavigators]) {
        hbdVC = [navigator primaryViewControllerWithViewController:vc];
        if (hbdVC) {
            break;
        }
    }
    return hbdVC;
}

- (NSArray *)routeGraph {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    NSMutableArray *root = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < application.windows.count; i ++) {
        UIWindow *window = application.windows[i];
        UIViewController *controller = window.rootViewController;
        
        if ([controller isKindOfClass:[HBDModalViewController class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)controller;
            if (!modal || modal.isBeingHidden) {
                continue;
            }
        }
        
        while (controller != nil) {
            [self buildRouteGraphWithController:controller root:root];
            UIViewController *presentedController = controller.presentedViewController;
            if (!presentedController) {
                break;
            }

            if ([presentedController isBeingDismissed]) {
                break;
            }
            
            if ([presentedController isKindOfClass:[UIAlertController class]]) {
                break;
            }
            controller = presentedController;
        }
    }
    
    return root;
}

- (void)buildRouteGraphWithController:(UIViewController *)controller root:(NSMutableArray *)root {
    for (id<HBDNavigator> navigator in [self.navigatorRegistry allNavigators]) {
        if ([navigator buildRouteGraphWithController:controller root:root]) {
            return;
        }
    }
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    id<HBDNavigator> navigator = [self.navigatorRegistry navigatorForAction:action];
    if (navigator) {
        [navigator handleNavigationWithViewController:target action:action extras:extras resolver:resolve rejecter:reject];
    } else {
        RCTLogWarn(@"找不到可以处理 action %@ 的 navigator", action);
    }
}

- (void)registerNavigator:(id<HBDNavigator>)navigator {
    [self.navigatorRegistry registerNavigator:navigator];
}

#pragma mark - bridge delegate

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
    return _jsCodeLocation;
}

@end
