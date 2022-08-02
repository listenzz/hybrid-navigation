#import <Foundation/Foundation.h>
#import "HBDViewController.h"
#import <React/RCTBridge.h>

@protocol HBDNavigator <NSObject>

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSArray<NSString *> *supportActions;

- (UIViewController *)createViewControllerWithLayout:(NSDictionary *)layout;

- (NSDictionary *)buildRouteGraphWithViewController:(UIViewController *)vc;

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc;

- (void)handleNavigationWithViewController:(UIViewController *)target action:(NSString *)action extras:(NSDictionary *)extras resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;

@end
