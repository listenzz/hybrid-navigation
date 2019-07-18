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

#import "HBDScreenNavigator.h"
#import "HBDStackNavigator.h"
#import "HBDTabNavigator.h"
#import "HBDDrawerNavigator.h"

#import "HBDEventEmitter.h"

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

+ (instancetype)get {
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

+ (instancetype)sharedInstance {
    return [self get];
}

- (instancetype)init {
    if (self = [super init]) {
        _nativeModules = [[NSMutableDictionary alloc] init];
        _reactModules = [[NSMutableDictionary alloc] init];
        _reactModuleRegisterCompleted = NO;
        _viewHierarchyReady = NO;
        _navigators = [[NSMutableArray alloc] init];
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
    
    if (self.hasRootLayout) {
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
        UIImage *image = [HBDUtils snapshotFromView:mainWindow];
        HBDViewController *primary = [self primaryViewController];
        UIBarStyle barStyle = primary.hbd_barStyle;
        if (mainWindow.rootViewController.presentedViewController && !mainWindow.rootViewController.presentedViewController.isBeingDismissed) {
            [mainWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
                [self showSnapshot:image barStyle:barStyle];
            }];
        } else {
            [self showSnapshot:image barStyle:barStyle];
        }
    }
}

- (void)showSnapshot:(UIImage *)snapshot barStyle:(UIBarStyle)barStyle {
    UIWindow *mainWindow = [self mainWindow];
    HBDViewController *vc = [[HBDViewController alloc] initWithModuleName:nil props:nil options:@{ @"topBarStyle": barStyle == UIBarStyleDefault ? @"dark-content" : @"light-content" }];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:mainWindow.bounds];
    imageView.image = snapshot;
    [vc.view addSubview:imageView];
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
        [self.delegate reactModuleRegisterDidCompleted:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ReactModuleRegistryDidCompletedNotification object:nil];
}

- (UIViewController *)controllerWithLayout:(NSDictionary *)layout {
    if (!self.isReactModuleRegisterCompleted) {
        return nil;
    }
    
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
            if (modal.isBeingHidden) {
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
    if (mainWindow.rootViewController.presentedViewController && !mainWindow.rootViewController.presentedViewController.isBeingDismissed) {
        [mainWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
            // [self performSelector:@selector(performSetRootViewController:) withObject:rootViewController afterDelay:0];
            [self performSetRootViewController:rootViewController];
        }];
    } else {
        [self performSetRootViewController:rootViewController];
    }
}

- (void)performSetRootViewController:(UIViewController *)rootViewController {
    UIWindow *mainWindow = [self mainWindow];
    [UIView transitionWithView:mainWindow duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
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
       [HBDEventEmitter sendEvent:EVENT_DID_SET_ROOT data:@{}];
    }];
}

- (HBDViewController *)primaryViewController {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    for (NSUInteger i = application.windows.count; i > 0; i--) {
        UIWindow *window = application.windows[i-1];
        if ([window isKindOfClass:[HBDModalWindow class]]) {
            HBDModalViewController *modal = (HBDModalViewController *)window.rootViewController;
            if (!modal.isBeingHidden) {
                return [self primaryViewControllerWithViewController:modal.contentViewController];
            }
        }
    }
    
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *controller = mainWindow.rootViewController;
    while (controller != nil) {
        UIViewController *presentedController = controller.presentedViewController;
        if (presentedController && ![presentedController isBeingDismissed]) {
            controller = presentedController;
        } else {
            break;
        }
    }
    return [self primaryViewControllerWithViewController:controller];
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    HBDViewController *hbdVC = nil;
    for (id<HBDNavigator> navigator in self.navigators) {
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
            if (modal.isBeingHidden) {
                continue;
            }
        }
        
        while (controller != nil) {
            [self buildRouteGraphWithController:controller root:root];
            UIViewController *presentedController = controller.presentedViewController;
            if (presentedController && !presentedController.isBeingDismissed) {
                controller = presentedController;
            } else {
                controller = nil;
            }
        }
    }
    
    return root;
}

- (void)buildRouteGraphWithController:(UIViewController *)controller root:(NSMutableArray *)root {
    for (id<HBDNavigator> navigator in self.navigators) {
        if ([navigator buildRouteGraphWithController:controller root:root]) {
            return;
        }
    }
}

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras {
    for (id<HBDNavigator> navigator in self.navigators) {
        NSArray<NSString *> *supportActions = navigator.supportActions;
        if ([supportActions containsObject:action]) {
            [navigator handleNavigationWithViewController:target action:action extras:extras];
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
