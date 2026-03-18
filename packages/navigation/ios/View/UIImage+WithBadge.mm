#import "UIImage+WithBadge.h"

@implementation UIImage (WithBadge)

- (UIImage *)withIconColor:(UIColor *)iconColor badgeColor:(UIColor *)badgeColor {
	CGSize imageSize = self.size;
	if (badgeColor == nil || CGColorGetAlpha(badgeColor.CGColor) <= 0.0) {
		UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
		UIImage *resultImage = [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
			UIImage *iconTintedImage = [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
			[iconColor set];
			[iconTintedImage drawAtPoint:CGPointZero];
		}];
		return [resultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	}

	static CGFloat const HBDTabBarBadgeHorizontalPadding = 8.0;
	static CGFloat const HBDTabBarBadgeVerticalPadding = 2.0;
	static CGFloat const HBDTabBarBadgeOffsetX = 0.0;
	static CGFloat const HBDTabBarBadgeOffsetY = 0.0;
	CGSize canvasSize = CGSizeMake(
		imageSize.width + HBDTabBarBadgeHorizontalPadding * 2,
		imageSize.height + HBDTabBarBadgeVerticalPadding * 2
	);
	
	UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:canvasSize];
	
	UIImage *resultImage = [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
		// 创建 tint 后的图标图片
		UIImage *iconTintedImage = [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		CGPoint iconOrigin = CGPointMake(
			(canvasSize.width - imageSize.width) / 2.0,
			(canvasSize.height - imageSize.height) / 2.0
		);
		CGRect iconFrame = CGRectMake(iconOrigin.x, iconOrigin.y, imageSize.width, imageSize.height);
		
		// 设置图标颜色并绘制
		[iconColor set];
		[iconTintedImage drawAtPoint:iconOrigin];
		
		// 创建徽章
		CGSize badgeSize = CGSizeMake(8, 8);
		CGPoint badgeOrigin = CGPointMake(
			CGRectGetMaxX(iconFrame) + HBDTabBarBadgeOffsetX,
			HBDTabBarBadgeOffsetY
		);
		CGRect badgeRect = CGRectMake(badgeOrigin.x, badgeOrigin.y, badgeSize.width, badgeSize.height);
		
		UIBezierPath *badgePath = [UIBezierPath bezierPathWithOvalInRect:badgeRect];
		[badgeColor setFill];
		[badgePath fill];
	}];
	
	return [resultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

// 提供默认参数的便捷方法
- (UIImage *)withIconColor:(UIColor *)iconColor {
	return [self withIconColor:iconColor badgeColor:[UITabBarItem appearance].badgeColor];
}

@end
