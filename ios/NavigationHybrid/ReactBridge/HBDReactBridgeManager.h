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

- (void)reactModuleRegisterDidCompleted:(HBDReactBridgeManager *)manager;

@end

@interface HBDReactBridgeManager : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, strong, readonly) RCTBridge *bridge;
@property(nonatomic, weak) id<HBDReactBridgeManagerDelegate> delegate;
@property(nonatomic, assign, readonly, getter=isReactModuleRegisterCompleted) BOOL reactModuleRegisterCompleted;
@property(nonatomic, assign) BOOL hasRootLayout;

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

- (UIViewController *)controllerForSceneId:(NSString *)sceneId;

- (void)setRootViewController:(UIViewController *)rootViewController;

- (NSArray *)routeGraph;

- (void)buildRouteGraphWithController:(UIViewController *)controller root:(NSMutableArray *)root;

- (HBDViewController *)primaryViewController;

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc;

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras;

- (void)registerNavigator:(id<HBDNavigator>)navigator;

@end
