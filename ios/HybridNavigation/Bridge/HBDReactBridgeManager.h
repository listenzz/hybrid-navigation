//
//  HBDReactBridgeManager.h
//  HybridNavigation
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <React/RCTBridge.h>
#import "HBDNavigator.h"

extern NSString *const ReactModuleRegistryDidCompletedNotification;
extern const NSInteger ResultOK;
extern const NSInteger ResultCancel;

@class HBDReactBridgeManager;
@class HBDViewController;

@protocol HBDReactBridgeManagerDelegate <NSObject>

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager;

@end

@interface HBDReactBridgeManager : NSObject

+ (instancetype)get;

@property(nonatomic, strong, readonly) RCTBridge *bridge;
@property(nonatomic, weak) id <HBDReactBridgeManagerDelegate> delegate;
@property(nonatomic, assign, readonly, getter=isReactModuleRegisterCompleted) BOOL reactModuleRegisterCompleted;
@property(nonatomic, assign, getter=isViewHierarchyReady) BOOL viewHierarchyReady;
@property(nonatomic, assign) BOOL hasRootLayout;

- (void)installWithBundleURL:(NSURL *)jsCodeLocation launchOptions:(NSDictionary *)launchOptions;

- (void)installWithBridge:(RCTBridge *)bridge;

- (void)registerNativeModule:(NSString *)moduleName forController:(Class)clazz;

- (BOOL)hasNativeModule:(NSString *)moduleName;

- (Class)nativeModuleClassFromName:(NSString *)moduleName;

- (void)registerReactModule:(NSString *)moduleName options:(NSDictionary *)options;

- (NSDictionary *)reactModuleOptionsForKey:(NSString *)moduleName;

- (BOOL)hasReactModuleForName:(NSString *)moduleName;

- (void)startRegisterReactModule;

- (void)endRegisterReactModule;

- (HBDViewController *)controllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

- (UIViewController *)controllerWithLayout:(NSDictionary *)layout;

- (UIViewController *)controllerForSceneId:(NSString *)sceneId;

- (void)setRootViewController:(UIViewController *)rootViewController;

- (void)setRootViewController:(UIViewController *)rootViewController withTag:(NSNumber *)tag;

- (NSArray *)routeGraph;

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc;

- (HBDViewController *)primaryViewController;

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc;

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;

- (void)registerNavigator:(id <HBDNavigator>)navigator;

@end
