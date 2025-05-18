#import "UITabBar+Badge.h"

@implementation UITabBar (DotBadge)

- (void)showDotBadgeAtIndex:(NSInteger)index {
    [self hideDotBadgeAtIndex:index];
    //label为小红点，并设置label属性
    UILabel *label = [[UILabel alloc] init];
    label.tag = 1000 + index;

    label.backgroundColor = [UITabBarItem appearance].badgeColor ?: [UIColor colorWithRed:1 green:58.0 / 255.0 blue:47. / 255. alpha:1];

    CGFloat percentX = (index + 0.5) / self.items.count;
    CGFloat x = ceilf((float) (percentX * self.frame.size.width + 8));
    CGFloat y = 6;
    //10为小红点的高度和宽度
    label.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:label];
    //把小红点移到最顶层
    [self bringSubviewToFront:label];

    [self styleLabel:label];
}

- (void)hideDotBadgeAtIndex:(NSInteger)index {
    for (UIView *subView in self.subviews) {
        if (subView.tag == 1000 + index) {
            [subView removeFromSuperview];
        }
    }
}

- (void)styleLabel:(UILabel *)label {
    CGRect rect = label.bounds;
    CGFloat radius = 4;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(radius, radius)];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    label.layer.mask = maskLayer;
}

@end
