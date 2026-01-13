#import "UIViewController+HBD.h"

#import <UIKit/UIKit.h>

@interface HBDViewController : UIViewController

@property(nonatomic, copy, readonly) NSString *moduleName;
@property(nonatomic, copy, readonly) NSDictionary *props;
@property(nonatomic, copy, readonly) NSDictionary *options;
@property(nonatomic, assign, readonly) BOOL animatedTransition;

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options NS_DESIGNATED_INITIALIZER;

- (void)setAppProperties:(NSDictionary *)props;

- (void)updateNavigationBarOptions:(NSDictionary *)options;

- (void)updateTabBarItem:(NSDictionary *)options;

@end
