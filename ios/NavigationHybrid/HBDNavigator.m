//
//  HBDNavigator.m
//
//  Created by Listen on 2017/11/25.
//

#import "HBDNavigator.h"
#import "HBDReactBridgeManager.h"
#import "HBDViewController.h"
#import "HBDReactViewController.h"
#import "HBDNavigationController.h"
#import "HBDUtils.h"

#import <React/RCTBridge.h>
#import <React/RCTLog.h>


NSInteger const RESULT_OK = -1;
NSInteger const RESULT_CANCEL = 0;

NSString * const ON_COMPONENT_RESULT_EVENT = @"ON_COMPONENT_RESULT";
NSString * const ON_BAR_BUTTON_ITEM_CLICK_EVENT = @"ON_BAR_BUTTON_ITEM_CLICK";

@interface HBDNavigator()

@property(nonatomic, strong, readonly) HBDReactBridgeManager *bridgeManager;

@property(nonatomic, assign) NSInteger requestCode;
@property(nonatomic, assign) NSInteger resultCode;
@property(nonatomic, copy) NSDictionary *resultData;
@property(nonatomic, copy) NSString *presentingNavId;

@end

@implementation HBDNavigator

+ (HBDNavigator *)navigatorForId:(NSString *)navId {
    UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
    UIViewController *controller = application.keyWindow.rootViewController;
    HBDNavigator *navigator = [self findNavigatorForId:navId atController:controller];
    return navigator;
}

+ (HBDNavigator *)findNavigatorForId:(NSString *)navId atController:(UIViewController *)controller {
    
    HBDNavigator *navigator;
    
    if ([controller isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *HDBNav = (HBDNavigationController *)controller;
        if ([HDBNav.navigator.navId isEqualToString:navId]) {
            navigator = HDBNav.navigator;
        }
    }
    
    if (!navigator) {
        UIViewController *presentedController = controller.presentedViewController;
        if(presentedController && ![presentedController isBeingDismissed]) {
            navigator = [self findNavigatorForId:navId atController:presentedController];
        }
    }
    
    if (!navigator && controller.childViewControllers.count > 0) {
        NSUInteger count = controller.childViewControllers.count;
        for (NSUInteger i = 0; i < count; i ++) {
            UIViewController *child = controller.childViewControllers[i];
            navigator = [self findNavigatorForId:navId atController:child];
            if (navigator) {
                break;
            }
        }
    }
    
    return navigator;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _bridgeManager = [HBDReactBridgeManager instance];
    _navId = [[NSUUID UUID] UUIDString];
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
    if ([self canPop] && self.resultData) {
        NSUInteger previous = self.navigationController.childViewControllers.count - 2;
        HBDViewController *vc = self.navigationController.childViewControllers[previous];
        [self sendResultTo:vc];
    }
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)sendResultTo:( HBDViewController *)vc {
    [vc didReceiveResultCode:self.resultCode resultData:self.resultData requestCode:0];
    self.resultCode = 0;
    self.resultData = nil;
}

- (void)popToScene:(NSString *)sceneId animated:(BOOL)animated {
    NSArray *children = self.navigationController.childViewControllers;
    HBDViewController *targetController;
    NSUInteger count = children.count;
    for (NSUInteger i = 0; i < count; i ++) {
        UIViewController *vc = [children objectAtIndex:i];
        if ([vc isKindOfClass:[HBDViewController class]]) {
            HBDViewController *hbdvc = (HBDViewController *)vc;
            if ([hbdvc.sceneId isEqualToString:sceneId]) {
                targetController = hbdvc;
                break;
            }
        }
    }
    
    if (targetController != nil) {
        if (self.resultData) {
            [self sendResultTo:targetController];
        }
        [self.navigationController popToViewController:targetController animated:animated];
    } else {
        RCTLogWarn(@"can't find the specified scene at current navigator");
    }
}

- (void)popToRootAnimated:(BOOL)animated {
    if ([self canPop] && self.resultData) {
        HBDViewController *vc = self.navigationController.childViewControllers[0];
        [self sendResultTo:vc];
    }
    [self.navigationController popToRootViewControllerAnimated:animated];
}

- (void)replaceModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    HBDViewController *vc = [self controllerWithModuleName:moduleName props:props options:options];
    NSMutableArray *children = [self.navigationController.childViewControllers mutableCopy];
    [children removeObjectAtIndex:children.count - 1];
    [children addObject:vc];
    [self.navigationController setViewControllers:[children copy] animated:NO];
}

- (void)replaceModule:(NSString *)moduleName {
    [self replaceModule:moduleName props:nil options:nil];
}

- (void)replaceToRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    HBDViewController *vc = [self controllerWithModuleName:moduleName props:props options:options];
    [self.navigationController setViewControllers:@[vc] animated:NO];
}

- (void)replaceToRootModule:(NSString *)moduleName {
    [self replaceToRootModule:moduleName props:nil options:nil];
}

- (void)presentModule:(NSString *)moduleName requestCode:(NSInteger) requestCode props:(NSDictionary *)props options:(NSDictionary *)options animated:(BOOL) animated {
    HBDNavigationController *presentedVC = [[HBDNavigationController alloc] initWithRootModule:moduleName props:props options:options];
    presentedVC.navigator.requestCode = requestCode;
    presentedVC.navigator.presentingNavId = self.navId;
    [self.navigationController presentViewController:presentedVC animated:animated completion:^{
        
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
    if (self.presentingNavId != nil) {
        HBDNavigator *navigator = [HBDNavigator navigatorForId:self.presentingNavId];
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
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:animated completion:^{
        
    }];
}

- (UIViewController *)topViewController {
    return self.navigationController.topViewController;
}

#pragma mark - private methods

- (HBDViewController *)controllerWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    HBDViewController *vc = nil;

    if (!props) {
        props = @{};
    }
    
    NSMutableDictionary *immediateProps = [props mutableCopy];
    [immediateProps setObject:self.navId forKey:@"navId"];
    [immediateProps setObject:[NSUUID UUID].UUIDString forKey:@"sceneId"];
    props = [immediateProps copy];
    
    if (!options) {
        options = @{};
    }

    if ([self.bridgeManager hasReactModuleForName:moduleName]) {
        NSDictionary *staticOptions = [[HBDReactBridgeManager instance] reactModuleOptionsForKey:moduleName];
        options = [HBDUtils mergeItem:options withTarget:staticOptions];
        vc = [[HBDReactViewController alloc] initWithNavigator:self moduleName:moduleName props:props options:options];
    } else {
        Class clazz =  [self.bridgeManager nativeModuleClassFromName:moduleName];
        NSCAssert([self.bridgeManager hasNativeModule:moduleName], @"找不到名为 %@ 的模块，你是否忘了注册？", moduleName);
        vc = [[clazz alloc] initWithNavigator:self props:props options:options];
    }
    return vc;
}

@end
