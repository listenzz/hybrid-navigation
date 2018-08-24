//
//  HBDUtils.h
//  NavigationHybrid
//
//  Created by Listen on 2017/12/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_STATIC_INLINE BOOL hasAlpha(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green= 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha < 1.0;
}


@interface HBDUtils : NSObject

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target;

+ (UIColor *)colorWithHexString: (NSString *) hexString;

+ (UIImage *)UIImage:(NSDictionary *)json;

+ (UIImage*)imageWithColor:(UIColor*)color;

+ (BOOL)isIphoneX;

@end
