#import "HBDReactBridgeManager.h"

#import "HBDUtils.h"
#import "HBDReactViewController.h"
#import "HBDNavigatorRegistry.h"
#import "HBDEventEmitter.h"

#import <React/RCTLog.h>

NSString *const ReactModuleRegistryDidCompletedNotification = @"ReactModuleRegistryDidCompletedNotification";
const NSInteger ResultOK = -1;
const NSInteger ResultCancel = 0;
const NSInteger ResultBlock = -2;

@interface HBDReactBridgeManager ()

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
    }
    return self;
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

- (void)invalidate {
    RCTLogInfo(@"[Navigation] HBDReactBridgeManager#invalidate");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSArray<id <HBDNavigator>> *navigators = [self.navigatorRegistry allNavigators];
    for (id<HBDNavigator> navigator in navigators) {
        [navigator invalidate];
    }

    self.viewHierarchyReady = NO;
    self.reactModuleRegisterCompleted = NO;
    self.didSetRoot = NULL;

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
    UIViewController *vc;
    @try {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
        vc = [storyboard instantiateInitialViewController];
    } @catch (NSException * e){
        vc = [UIViewController new];
        vc.view.backgroundColor = UIColor.whiteColor;
    }
    mainWindow.rootViewController = vc;
}

- (void)installWithBridge:(RCTBridge *)bridge {
    _bridge = bridge;
}

- (void)registerNativeModule:(NSString *)moduleName forViewController:(Class)clazz {
    [_nativeModules setObject:clazz forKey:moduleName];
}

- (BOOL)hasNativeModule:(NSString *)moduleName {
    return _nativeModules[moduleName] != nil;
}

- (Class)nativeModuleClass:(NSString *)moduleName {
    return _nativeModules[moduleName];
}

- (void)registerReactModule:(NSString *)moduleName options:(NSDictionary *)options {
    _reactModules[moduleName] = options;
}

- (NSDictionary *)reactModuleOptions:(NSString *)moduleName {
    return _reactModules[moduleName];
}

- (BOOL)hasReactModule:(NSString *)moduleName {
    return _reactModules[moduleName] != nil;
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

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout {
    NSArray<NSString *> *layouts = [self.navigatorRegistry allLayouts];
    for (NSString *name in layouts) {
        if (![[layout allKeys] containsObject:name]) {
            continue;
        }
        
        id <HBDNavigator> navigator = [self.navigatorRegistry navigatorForLayout:name];
        UIViewController *vc = [navigator viewControllerWithLayout:layout];
        if (vc) {
            [self.navigatorRegistry setLayout:name forViewController:vc];
        }
        return vc;
    }
    
    return nil;
}

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    if (!self.isReactModuleRegisterCompleted) {
        return nil;
    }

    UIViewController *vc = [self createViewControllerWithLayout:layout];
    
    if (!vc) {
        RCTLogError(@"[Navigation] Can't find a navigator that can handle layout '%@'. Did you forget to register?", layout);
        return nil;
    }

    return vc;
}

- (HBDViewController *)viewControllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    if (!self.isReactModuleRegisterCompleted) {
        @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"React module hasn't register completed." userInfo:@{}];
    }

    if (!props) {
        props = @{};
    }

    if (!options) {
        options = @{};
    }

    if ([self hasReactModule:moduleName]) {
        NSDictionary *staticOptions = [[HBDReactBridgeManager get] reactModuleOptions:moduleName];
        options = [HBDUtils mergeItem:options withTarget:staticOptions];
        return [[HBDReactViewController alloc] initWithModuleName:moduleName props:props options:options];
    } else {
        Class clazz = [self nativeModuleClass:moduleName];
        NSCAssert([self hasNativeModule:moduleName], @"Can't find module named with %@ , do you forget to register？", moduleName);
        return [[clazz alloc] initWithModuleName:moduleName props:props options:options];
    }
}

- (UIViewController *)viewControllerBySceneId:(NSString *)sceneId {
    UIWindow *window = [self mainWindow];
    return [self viewControllerWithSceneId:sceneId viewController:window.rootViewController];
}

- (UIViewController *)viewControllerWithSceneId:(NSString *)sceneId viewController:(UIViewController *)vc {
    if ([vc.sceneId isEqualToString:sceneId]) {
        return vc;
    }

    UIViewController *presentedViewController = vc.presentedViewController;
    if (presentedViewController && ![presentedViewController isBeingDismissed]) {
        UIViewController *target = [self viewControllerWithSceneId:sceneId viewController:presentedViewController];
        if (target) {
            return target;
        }
    }

    NSArray<UIViewController *> *children = vc.childViewControllers;
    if (children.count == 0) {
        return nil;
    }

    for (UIViewController *child in children) {
        UIViewController *target = [self viewControllerWithSceneId:sceneId viewController:child];
        if (target) {
            return target;
        }
    }

    return nil;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *presentedViewController = mainWindow.rootViewController.presentedViewController;
    if (presentedViewController && !presentedViewController.isBeingDismissed) {
        [mainWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self performSetRootViewController:rootViewController animated:NO];
        }];
    } else {
        [self performSetRootViewController:rootViewController animated:YES];
    }
}

- (void)performSetRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated {
    [HBDEventEmitter sendEvent:EVENT_WILL_SET_ROOT data:@{}];
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
        } completion:^(BOOL finished) {
            self.viewHierarchyReady = YES;
            if (self.didSetRoot) {
                self.didSetRoot(@[NSNull.null, @YES]);
                self.didSetRoot = NULL;
            }
            [HBDEventEmitter sendEvent:EVENT_DID_SET_ROOT data:@{}];
        }];
    } else {
        mainWindow.rootViewController = rootViewController;
        mainWindow.windowLevel = UIWindowLevelNormal;
        if (!mainWindow.isKeyWindow) {
            [mainWindow makeKeyAndVisible];
        }
        
        self.viewHierarchyReady = YES;
        if (self.didSetRoot) {
            self.didSetRoot(@[NSNull.null, @YES]);
            self.didSetRoot = NULL;
        }
        [HBDEventEmitter sendEvent:EVENT_DID_SET_ROOT data:@{}];
    }
}

- (HBDViewController *)primaryViewController {
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *controller = mainWindow.rootViewController;
    return [self primaryViewControllerWithViewController:controller];
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    UIViewController *presented = vc.presentedViewController;
    if (presented && !presented.beingDismissed && ![presented isKindOfClass:[UIAlertController class]]) {
        return [self primaryViewControllerWithViewController:presented];
    }

    NSString *layout = [self.navigatorRegistry layoutForViewController:vc];
    if (layout) {
        id <HBDNavigator> navigator = [self.navigatorRegistry navigatorForLayout:layout];
        return [navigator primaryViewControllerWithViewController:vc];
    }
    
    return nil;
}

- (NSArray *)routeGraph {
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *vc = mainWindow.rootViewController;
    NSDictionary *graph = [self routeGraphWithViewController:vc];
    NSMutableArray *root = [[NSMutableArray alloc] init];
    [root addObject:graph];
    [root addObjectsFromArray:[self presentedGraphsWithRootViewController:vc]];
    return root;
}

- (NSArray *)presentedGraphsWithRootViewController:(UIViewController *)vc {
    NSMutableArray *graphs = [[NSMutableArray alloc] init];
    UIViewController *presented = vc.presentedViewController;
    
    while (presented && !presented.beingDismissed && ![presented isKindOfClass:[UIAlertController class]]) {
        NSDictionary *graph = [self routeGraphWithViewController:presented];
        if (graph) {
            [graphs addObject:graph];
        }
        presented = presented.presentedViewController;
    }
    
    return graphs;
}

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc {
    NSString *layout = [self.navigatorRegistry layoutForViewController:vc];
    if (layout) {
        id <HBDNavigator> navigator = [self.navigatorRegistry navigatorForLayout:layout];
        return [navigator routeGraphWithViewController:vc];
    }
    return nil;
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    id <HBDNavigator> navigator = [self.navigatorRegistry navigatorForAction:action];
    if (!navigator) {
        RCTLogInfo(@"[Navigation] Can't find a navigator that can handle action '%@'", action);
        callback(@[NSNull.null, @NO]);
        return;
    }
    [navigator handleNavigationWithViewController:vc action:action extras:extras callback:(RCTResponseSenderBlock)callback];
}

- (void)registerNavigator:(id <HBDNavigator>)navigator {
    [self.navigatorRegistry registerNavigator:navigator];
}

@end
