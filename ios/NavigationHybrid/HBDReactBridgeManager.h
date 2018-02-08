//
//  HBDReactBridgeManager.h
//
//  Created by Listen on 2017/11/25.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>
#import "HBDViewController.h"


extern NSString * const ReactModuleRegistryDidCompletedNotification;

@class HBDReactBridgeManager;

@protocol HBDReactBridgeManagerDelegate <NSObject>

- (void)reactModuleRegistryDidCompleted:(HBDReactBridgeManager *)manager;

@end

@interface HBDReactBridgeManager : NSObject

@property(nonatomic, strong, readonly) RCTBridge *bridge;
@property(nonatomic, weak) id<HBDReactBridgeManagerDelegate> delegate;

+ (instancetype)instance;

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

- (void)setRootViewController:(UIViewController *)rootViewController;

@end
