#import <UIKit/UIKit.h>

@interface HBDTabBarController : UITabBarController

- (void)updateTabBar:(NSDictionary *)options;

- (void)setTabItem:(NSArray<NSDictionary *> *)options;

@end
