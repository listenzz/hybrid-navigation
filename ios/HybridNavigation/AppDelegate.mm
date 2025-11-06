#import "AppDelegate.h"

#import <React-RCTAppDelegate/RCTDefaultReactNativeFactoryDelegate.h>
#import <React-RCTAppDelegate/RCTReactNativeFactory.h>
#import <ReactAppDependencyProvider/RCTAppDependencyProvider.h>

#import <React/RCTLinkingManager.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLog.h>

#import <HybridNavigation/HybridNavigation.h>
#import "NativeViewController.h"


@interface ReactNativeDelegate : RCTDefaultReactNativeFactoryDelegate
@end

@implementation ReactNativeDelegate

- (NSURL *)bundleURL {
#if DEBUG
	return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
	return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end


@interface AppDelegate () <HBDReactBridgeManagerDelegate>

@property (strong, nonatomic) RCTRootViewFactory *rootViewFactory;
@property (strong, nonatomic) id<RCTReactNativeFactoryDelegate> reactNativeDelegate;
@property (strong, nonatomic) RCTReactNativeFactory *reactNativeFactory;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RCTSetLogThreshold(RCTLogLevelInfo);
	
	ReactNativeDelegate *delegate = [[ReactNativeDelegate alloc] init];
	RCTReactNativeFactory *factory = [[RCTReactNativeFactory alloc] initWithDelegate:delegate];
	delegate.dependencyProvider = [[RCTAppDependencyProvider alloc] init];
	
	
	self.reactNativeDelegate = delegate;
	self.reactNativeFactory = factory;
	self.rootViewFactory = factory.rootViewFactory;
	
	[self.rootViewFactory initializeReactHostWithLaunchOptions:launchOptions];
	[[HBDReactBridgeManager get] installWithReactHost:self.rootViewFactory.reactHost];
    
    // register native modules
    [[HBDReactBridgeManager get] registerNativeModule:@"NativeModule" forViewController:[NativeViewController class]];
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateInitialViewController];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager {
    
}

// iOS 9.x or newer
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [RCTLinkingManager application:application openURL:url options:options];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [GlobalStyle globalStyle].interfaceOrientation;
}


@end
