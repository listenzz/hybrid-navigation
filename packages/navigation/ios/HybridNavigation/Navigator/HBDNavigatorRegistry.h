#import "HBDNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBDNavigatorRegistry : NSObject

- (void)registerNavigator:(id <HBDNavigator>)navigator;

- (id <HBDNavigator>)navigatorForAction:(NSString *)action;

- (id <HBDNavigator>)navigatorForLayout:(NSString *)layout;

- (NSString *)layoutForViewController:(UIViewController *)vc;

- (void)setLayout:(NSString *)layout forViewController:(UIViewController *)vc;

- (NSArray<NSString *> *)allLayouts;

- (NSArray<id<HBDNavigator>> *)allNavigators;

@end

NS_ASSUME_NONNULL_END
