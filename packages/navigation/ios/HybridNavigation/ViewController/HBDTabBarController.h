#import <UIKit/UIKit.h>

@interface HBDTabBarController : UITabBarController

@property(nonatomic, assign) BOOL intercepted;

- (instancetype)initWithTabBarOptions:(NSDictionary *)options;

- (void)updateTabBar:(NSDictionary *)options;

- (void)setTabItem:(NSArray<NSDictionary *> *)options;

@end
