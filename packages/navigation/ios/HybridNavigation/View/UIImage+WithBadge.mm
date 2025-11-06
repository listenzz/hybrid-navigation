#import "UIImage+WithBadge.h"

@implementation UIImage (WithBadge)

- (UIImage *)withIconColor:(UIColor *)iconColor badgeColor:(UIColor *)badgeColor {
	CGSize imageSize = self.size;
	
	UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
	
	UIImage *resultImage = [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
		// 创建 tint 后的图标图片
		UIImage *iconTintedImage = [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		
		// 设置图标颜色并绘制
		[iconColor set];
		[iconTintedImage drawAtPoint:CGPointZero];
		
		// 创建徽章
		CGSize badgeSize = CGSizeMake(8, 8);
		CGPoint badgeOrigin = CGPointMake(imageSize.width - badgeSize.width, 0);
		CGRect badgeRect = CGRectMake(badgeOrigin.x, badgeOrigin.y, badgeSize.width, badgeSize.height);
		
		UIBezierPath *badgePath = [UIBezierPath bezierPathWithOvalInRect:badgeRect];
		[badgeColor setFill];
		[badgePath fill];
	}];
	
	return [resultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

// 提供默认参数的便捷方法
- (UIImage *)withIconColor:(UIColor *)iconColor {
	return [self withIconColor:iconColor badgeColor:[UIColor clearColor]];
}


- (UIImage *)withBadgeColor:(UIColor *)badgeColor {
	CGSize imageSize = self.size;
		
	UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
	
	return [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
		// 绘制原始图片
		[self drawAtPoint:CGPointZero];
		
		// 创建徽章
		CGSize badgeSize = CGSizeMake(8, 8);
		CGPoint badgeOrigin = CGPointMake(imageSize.width - badgeSize.width, 0);
		CGRect badgeRect = CGRectMake(badgeOrigin.x, badgeOrigin.y, badgeSize.width, badgeSize.height);
		
		UIBezierPath *badgePath = [UIBezierPath bezierPathWithOvalInRect:badgeRect];
		[badgeColor setFill];
		[badgePath fill];
	}];
}

@end
