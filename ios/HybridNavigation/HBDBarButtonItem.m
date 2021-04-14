//
//  HBDBarButtonItem.m
//  HybridNavigation
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDBarButtonItem.h"

@implementation HBDBarButton

- (CGSize)intrinsicContentSize {
    return CGSizeMake(32, 32);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGSize acturalSize = self.frame.size;
    CGSize minimumSize = CGSizeMake(40, 40);
    CGFloat verticalMargin = acturalSize.height - minimumSize.height >= 0 ? 0 : ((minimumSize.height - acturalSize.height ) / 2);
    CGFloat horizontalMargin = acturalSize.width - minimumSize.width >= 0 ? 0 : ((minimumSize.width - acturalSize.width ) / 2);
    CGRect newArea = CGRectMake(self.bounds.origin.x - horizontalMargin, self.bounds.origin.y - verticalMargin, self.bounds.size.width + 2 * horizontalMargin, self.bounds.size.height + 2 * verticalMargin);
    return CGRectContainsPoint(newArea, point);
}

- (UIEdgeInsets)alignmentRectInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(self.alignmentRectInsetsOverride, UIEdgeInsetsZero)) {
        return super.alignmentRectInsets;
    } else {
        return self.alignmentRectInsetsOverride;
    }
}

@end

@interface HBDBarButtonItem()

@end

@implementation HBDBarButtonItem

- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style {
    HBDBarButton *button = [HBDBarButton buttonWithType:UIButtonTypeSystem];
    if(@available(iOS 11, *)){
        button.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [button setFrame:CGRectMake(0, 0, 32, 32)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didButtonClick) forControlEvents:UIControlEventTouchUpInside];
    return [super initWithCustomView:button];
}

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style {
    return [super initWithTitle:title style:style target:self action:@selector(didButtonClick)];
}

- (void)didButtonClick {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end
