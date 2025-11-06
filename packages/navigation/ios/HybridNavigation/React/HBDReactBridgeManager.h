#import <React/RCTBridge.h>
#import "HBDNavigator.h"
#import <React-RuntimeApple/ReactCommon/RCTHost.h>

extern NSString *const ReactModuleRegistryDidCompletedNotification;
extern const NSInteger ResultOK;
extern const NSInteger ResultCancel;
extern const NSInteger ResultBlock;

@class HBDReactBridgeManager;
@class HBDViewController;

@protocol HBDReactBridgeManagerDelegate <NSObject>

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager;

@end

@interface HBDReactBridgeManager : NSObject

+ (instancetype)get;

@property(nonatomic, strong, readonly) RCTBridge *bridge;
@property(nonatomic, strong, readonly) RCTHost *rctHost;
@property(nonatomic, weak) id <HBDReactBridgeManagerDelegate> delegate;
@property(nonatomic, assign, readonly, getter=isReactModuleRegisterCompleted) BOOL reactModuleRegisterCompleted;
@property(nonatomic, assign, getter=isViewHierarchyReady) BOOL viewHierarchyReady;
@property(nonatomic, assign) BOOL hasRootLayout;
@property(nonatomic, copy) RCTResponseSenderBlock didSetRoot;

- (void)installWithReactHost:(RCTHost *)rctHost;

- (void)registerNativeModule:(NSString *)moduleName forViewController:(Class)clazz;

- (BOOL)hasNativeModule:(NSString *)moduleName;

- (Class)nativeModuleClass:(NSString *)moduleName;

- (void)registerReactModule:(NSString *)moduleName options:(NSDictionary *)options;

- (NSDictionary *)reactModuleOptions:(NSString *)moduleName;

- (BOOL)hasReactModule:(NSString *)moduleName;

- (void)startRegisterReactModule;

- (void)endRegisterReactModule;

- (HBDViewController *)viewControllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout;

- (UIViewController *)viewControllerBySceneId:(NSString *)sceneId;

- (void)setRootViewController:(UIViewController *)rootViewController;

- (NSArray *)routeGraph;

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc;

- (HBDViewController *)primaryViewController;

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc;

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback;

- (void)registerNavigator:(id<HBDNavigator>)navigator;

- (void)invalidate;

@end
