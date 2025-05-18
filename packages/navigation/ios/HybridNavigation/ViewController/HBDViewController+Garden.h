#import "HBDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBDViewController (Garden)

- (void)setLeftBarButtonItem:(NSDictionary *)item;

- (void)setRightBarButtonItem:(NSDictionary *)item;

- (void)setLeftBarButtonItems:(NSArray *)items;

- (void)setRightBarButtonItems:(NSArray *)items;

- (void)setPassThroughTouches:(BOOL)passThrough;

@end

NS_ASSUME_NONNULL_END
