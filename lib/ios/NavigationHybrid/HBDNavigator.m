//
//  HBDNavigator.m
//  Pods
//
//  Created by Listen on 2017/11/25.
//

#import "HBDNavigator.h"
#import "HBDViewController.h"
#import "HBDReactBridgeManager.h"

NSInteger const RESULT_OK = -1;
NSInteger const RESULT_CANCEL = 0;

@interface HBDNavigator()

@property(nonatomic, strong) HBDReactBridgeManager *bridgeManager;
@property(nonatomic, assign) NSInteger requestCode;
@property(nonatomic, assign) NSInteger resultCode;
@property(nonatomic, copy) NSDictionary *resultData;
@property(nonatomic, copy) NSString *presentingNavId;

@end

@implementation HBDNavigator

- (instancetype)initWithRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options  reactBridgeManager:(HBDReactBridgeManager *)bridgeManager {
    self = [super init];
    if (!self) {
        return nil;
    }
    _bridgeManager = bridgeManager;
    _navId = [[NSUUID UUID] UUIDString];
    HBDViewController *vc = [self controllerWithModuleName:moduleName props:props options:options];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    _resultCode = RESULT_CANCEL;
    return self;
}

#pragma mark - public methods

- (void)pushModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL) animated {
    HBDViewController *vc = [self controllerWithModuleName:moduleName props:props options:options];
    [self.navigationController pushViewController:vc animated:animated];
}

- (void)pushModule:(NSString *)moduleName {
    [self pushModule:moduleName props:nil options:nil animated:YES];
}

- (BOOL)canPop {
    return self.navigationController.childViewControllers.count > 1;
}

- (void)popAnimated:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)popToRootAnimated:(BOOL)animated {
    [self.navigationController popToRootViewControllerAnimated:animated];
}

- (void)presentModule:(NSString *)moduleName requestCode:(NSInteger) requestCode props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL) animated {
    HBDNavigator *navigator = [[HBDNavigator alloc] initWithRootModule:moduleName props:props options:options reactBridgeManager:self.bridgeManager];
    navigator.requestCode = requestCode;
    navigator.presentingNavId = self.navId;
    [self.bridgeManager registerNavigator:navigator];
    [self.navigationController presentViewController:navigator.navigationController animated:animated completion:^{
        
    }];
}

- (void)presentModule:(NSString *)moduleName requestCode:(NSInteger) requestCode {
    [self presentModule:moduleName requestCode:requestCode props:nil options:nil animated:YES];
}

- (void)setResultCode:(NSInteger)resultCode data:(NSDictionary *)data {
    self.resultCode = resultCode;
    self.resultData = data;
}

- (BOOL)canDismiss {
    return self.presentingNavId != nil;
}

- (void)dismissAnimated:(BOOL)animated {
    __weak typeof (self) weakSelf = self;
    
    if (self.presentingNavId != nil) {
        HBDNavigator *navigator = [self.bridgeManager navigatorForNavId:self.presentingNavId];
        if (navigator != nil) {
            NSUInteger count = navigator.navigationController.childViewControllers.count;
            if (count > 0) {
                UIViewController *vc = navigator.navigationController.childViewControllers[count -1];
                if ([vc isKindOfClass:HBDViewController.class]) {
                    HBDViewController *hbdvc = (HBDViewController *)vc;
                    [hbdvc didReceiveResultCode:self.resultCode resultData:self.resultData requestCode:self.requestCode];
                }
            }
        }
    }
    
    [self.navigationController dismissViewControllerAnimated:animated completion:^{
        [weakSelf.bridgeManager unregisterNavigator:weakSelf];
    }];
}

#pragma mark - private methods

- (HBDViewController *)controllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options  {
    HBDViewController *vc = nil;
    if ([self.bridgeManager hasReactModuleForName:moduleName]) {
        
    } else {
        Class clazz =  [self.bridgeManager nativeModuleClassFromName:moduleName];
        NSCAssert([self.bridgeManager hasNativeModule:moduleName], @"找不到名为 %@ 的模块，你是否忘了注册？", moduleName);
        vc = [[clazz alloc] initWithNavigator:self];
    }
    return vc;
}

@end
