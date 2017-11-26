//
//  HBDNavigator.h
//  Pods
//
//  Created by Listen on 2017/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSInteger const RESULT_OK;
UIKIT_EXTERN NSInteger const RESULT_CANCEL;

@class HBDReactBridgeManager;

@interface HBDNavigator : NSObject

@property(nonatomic, strong, readonly) UINavigationController *navigationController;
@property(nonatomic, copy, readonly) NSString *navId;

- (instancetype)initWithRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options reactBridgeManager:(HBDReactBridgeManager *)manager;

- (void)pushModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL) animated;

- (void)pushModule:(NSString *)moduleName;

- (BOOL)canPop;

- (void)popAnimated:(BOOL)animated;

- (void)popToRootAnimated:(BOOL)animated;

- (void)presentModule:(NSString *)moduleName requestCode:(NSInteger) requestCode props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL) animated;

- (void)presentModule:(NSString *)moduleName requestCode:(NSInteger) requestCode;

- (void)setResultCode:(NSInteger)resultCode data:(NSDictionary *)data;

- (BOOL)canDismiss;

- (void)dismissAnimated:(BOOL)animated;

@end
