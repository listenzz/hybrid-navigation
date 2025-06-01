#import <UIKit/UIKit.h>
#import <objc/runtime.h>

UIKIT_STATIC_INLINE BOOL colorHasAlphaComponent(UIColor *color) {
    if (!color) {
        return YES;
    }
    return CGColorGetAlpha(color.CGColor) < 1.0;
}

UIKIT_STATIC_INLINE BOOL imageHasAlphaChannel(UIImage *image) {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

UIKIT_STATIC_INLINE void hbd_exchangeImplementations(Class clazz, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);

    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
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

+ (CGFloat)statusBarHeight;

+ (BOOL)isIphoneX;

+ (BOOL)isInCall;

+ (void)printViewHierarchy:(UIView *)view withPrefix:(NSString *)prefix;

@end
