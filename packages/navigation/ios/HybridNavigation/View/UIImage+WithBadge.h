#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (WithBadge)

- (UIImage *)withIconColor:(UIColor *)iconColor;

- (UIImage *)withIconColor:(UIColor *)iconColor badgeColor:(UIColor *)badgeColor;

- (UIImage *)withBadgeColor:(UIColor *)badgeColor;

@end

NS_ASSUME_NONNULL_END
