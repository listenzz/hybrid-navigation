#import "HBDViewController.h"

#import <React/RCTBridge.h>

@protocol HBDNavigator <NSObject>

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSArray<NSString *> *supportActions;

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout;

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc;

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc;

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback;

- (void)invalidate;

@end
