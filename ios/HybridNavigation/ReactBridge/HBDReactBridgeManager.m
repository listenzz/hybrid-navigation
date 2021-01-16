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
    for (NSString *name in layouts) {
        if ([[layout allKeys] containsObject:name]) {
            id<HBDNavigator> navigator = [self.navigatorRegistry navigatorForLayout:name];
            UIViewController *vc = [navigator createViewControllerWithLayout:layout];
            if (vc) {
                [self.navigatorRegistry setLayout:name forViewController:vc];
            }
            return vc;
        }
    }
    
    RCTLogError(@"找不到可以处理 %@ 的 navigator，你是否忘了注册？", layout);
    return nil;
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
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *controller = mainWindow.rootViewController;
    return [self primaryViewControllerWithViewController:controller];
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    HBDModalViewController *modal = vc.hbd_popupViewController.hbd_modalViewController;
    if (modal && !modal.isBeingHidden) {
        return [self primaryViewControllerWithViewController:modal.contentViewController];
    }
    
    UIViewController *presented = vc.presentedViewController;
    if (presented && !presented.beingDismissed && ![presented isKindOfClass:[UIAlertController class]]) {
        return [self primaryViewControllerWithViewController:presented];
    }
    
    NSString *layout = [self.navigatorRegistry layoutForViewController:vc];
    if (layout) {
        id<HBDNavigator> navigator = [self.navigatorRegistry navigatorForLayout:layout];
        return [navigator primaryViewControllerWithViewController:vc];
    }
    
    return nil;
}

- (NSArray *)routeGraph {
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *vc = mainWindow.rootViewController;
    NSMutableDictionary *graph = [self buildRouteGraphWithViewController:vc];
    
    NSMutableArray *root = [[NSMutableArray alloc] init];
    NSMutableArray *modal = [[NSMutableArray alloc] init];
    NSMutableArray *present = [[NSMutableArray alloc] init];
    
    [self extrackModal:modal present:present withGraph:graph];
    
    if (graph) {
        [root addObject:graph];
    }
    
    if ([present count] > 0) {
        [root addObjectsFromArray:present];
    }
    
    if ([modal count] > 0) {
        [root addObjectsFromArray:modal];
    }
    
    return root;
}

- (void)extrackModal:(NSMutableArray *)modal present:(NSMutableArray *)present withGraph:(NSMutableDictionary *)graph {
    NSMutableDictionary *m = graph[@"ref_modal"];
    NSMutableDictionary *p = graph[@"ref_present"];
    if (m) {
        [graph removeObjectForKey:@"ref_modal"];
        [modal addObject:m];
        [self extrackModal:modal present:present withGraph:m];
    }
    
    if (p) {
        [graph removeObjectForKey:@"ref_present"];
        [present addObject:p];
        [self extrackModal:modal present:present withGraph:p];
    }
    
    NSArray *children = graph[@"children"];
    if (children) {
        for (int i = 0; i < children.count; i++) {
            NSMutableDictionary *child = [children objectAtIndex:i];
            [self extrackModal:modal present:present withGraph:child];
        }
    }
}

- (NSMutableDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc {
    NSMutableDictionary *m = nil;
    HBDModalViewController *modal = vc.hbd_popupViewController.hbd_modalViewController;
    if (modal && !modal.isBeingHidden) {
        m = [self buildRouteGraphWithViewController:modal.contentViewController];
    }
    
    NSMutableDictionary *p = nil;
    UIViewController *presented = vc.presentedViewController;
    if (presented && presented.presentingViewController == vc && !presented.beingDismissed && ![presented isKindOfClass:[UIAlertController class]]) {
        p = [self buildRouteGraphWithViewController:presented];
    }
    
    NSString *layout = [self.navigatorRegistry layoutForViewController:vc];
    if (layout) {
        id<HBDNavigator> navigator = [self.navigatorRegistry navigatorForLayout:layout];
        NSMutableDictionary *graph = [[navigator buildRouteGraphWithViewController:vc] mutableCopy];
        if (m) {
            [graph setObject:m forKey:@"ref_modal"];
        }
        if (p) {
            [graph setObject:p forKey:@"ref_present"];
        }
        return graph;
    }
    
    return nil;
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
