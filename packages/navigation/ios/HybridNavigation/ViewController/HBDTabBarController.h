#import <UIKit/UIKit.h>

@interface HBDTabBarController : UITabBarController

@property(nonatomic, assign) BOOL intercepted;

- (void)updateTabBar:(NSDictionary *)options;

- (void)setTabItem:(NSArray<NSDictionary *> *)options;

@end
