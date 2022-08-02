#import <UIKit/UIKit.h>
#import <objc/runtime.h>

UIKIT_STATIC_INLINE BOOL colorHasAlphaComponent(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green = 0;
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

UIKIT_STATIC_INLINE void hbd_exchangeImplementations(Class klass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(klass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(klass, swizzledSelector);

    BOOL success = class_addMethod(klass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(klass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface HBDUtils : NSObject

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (NSString *)hexStringFromColor:(UIColor *)color;

+ (UIImage *)UIImage:(NSDictionary *)json;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (NSString *)iconUriFromUri:(NSString *)uri;

+ (BOOL)isIphoneX;

+ (BOOL)isInCall;

@end
