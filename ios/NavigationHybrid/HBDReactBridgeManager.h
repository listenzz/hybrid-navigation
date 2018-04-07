//
//  HBDReactBridgeManager.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <React/RCTBridge.h>
#import "HBDViewController.h"

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

+ (instancetype)sharedInstance;

- (void)installWithBundleURL:jsCodeLocation launchOptions:(NSDictionary *)launchOptions;

- (void)registerNativeModule:(NSString *)moduleName forController:(Class)clazz;

- (BOOL)hasNativeModule:(NSString *)moduleName;

- (Class)nativeModuleClassFromName:(NSString *)moduleName;

- (void)registerReactModule:(NSString *)moduleName options:(NSDictionary *)options;

- (NSDictionary *)reactModuleOptionsForKey:(NSString *)moduleName;

- (BOOL)hasReactModuleForName:(NSString *)moduleName;

- (BOOL)isReactModuleInRegistry;

- (void)startRegisterReactModule;

- (void)endRegisterReactModule;

- (HBDViewController *)controllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

- (UIViewController *)controllerWithLayout:(NSDictionary *)layout;

- (void)setRootViewController:(UIViewController *)rootViewController;

@end
