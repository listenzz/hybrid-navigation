//
//  HBDReactBridgeManager.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <React/RCTBridge.h>
#import "HBDViewController.h"
#import "HBDNavigator.h"

extern NSString * const ReactModuleRegistryDidCompletedNotification;
extern const NSInteger ResultOK;
extern const NSInteger ResultCancel;

@class HBDReactBridgeManager;

@protocol HBDReactBridgeManagerDelegate <NSObject>

- (void)reactModuleRegistryDidCompleted:(HBDReactBridgeManager *)manager;

@end

@interface HBDReactBridgeManager : NSObject

@property(nonatomic, strong, readonly) RCTBridge *bridge;
@property(nonatomic, weak) id<HBDReactBridgeManagerDelegate> delegate;
@property(nonatomic, assign, readonly, getter=isReactModuleRegisterCompleted) BOOL reactModuleRegisterCompleted;

+ (instancetype)sharedInstance;

- (void)installWithBundleURL:jsCodeLocation launchOptions:(NSDictionary *)launchOptions;

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

- (HBDViewController *)controllerForSceneId:(NSString *)sceneId;

- (void)setRootViewController:(UIViewController *)rootViewController;

- (void)routeGraphWithController:(UIViewController *)controller container:(NSMutableArray *)container;

- (HBDViewController *)primaryChildViewControllerInController:(UIViewController *)vc;

- (void)handleNavigationWithViewController:(HBDViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras;

- (void)registerNavigator:(id<HBDNavigator>)navigator;

@end
