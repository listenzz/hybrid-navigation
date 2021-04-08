//
//  HBDUtils.h
//  NavigationHybrid
//
//  Created by Listen on 2017/12/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

UIKIT_STATIC_INLINE BOOL colorHasAlphaComponent(UIColor *color) {
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

UIKIT_STATIC_INLINE BOOL imageHasAlphaChannel(UIImage *image) {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

UIKIT_STATIC_INLINE void hbd_exchangeImplementations(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface HBDUtils : NSObject

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target;

+ (UIColor *)colorWithHexString: (NSString *) hexString;

+ (UIImage *)UIImage:(NSDictionary *)json;

+ (UIImage*)imageWithColor:(UIColor*)color;

+ (NSString *)iconUriFromUri:(NSString *)uri;

+ (BOOL)isIphoneX;

+ (BOOL)isInCall;

@end
