#import "HBDUtils.h"

#import <React/RCTConvert.h>

@implementation HBDUtils

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target {
    NSMutableDictionary *mutableTarget = [target mutableCopy];
    for (NSString *key in [item allKeys]) {
        id obj = item[key];
        if (obj == nil) {
            //ignore
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *subTarget = target[key];
            if (RCTNilIfNull(subTarget)) {
                mutableTarget[key] = [self mergeItem:obj withTarget:subTarget];
            } else {
                mutableTarget[key] = obj;
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *array = target[key];
            if (array) {
                NSArray *items = obj;
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < array.count; i++) {
                    NSDictionary *dict = [self mergeItem:items[i] withTarget:array[i]];
                    [result addObject:dict];
                }
                mutableTarget[key] = result;
            } else {
                mutableTarget[key] = obj;
            }
        } else {
            mutableTarget[key] = obj;
        }
    }

    return [mutableTarget copy];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, green, blue;
    switch ([colorString length]) {
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            [NSException raise:@"Invalid color value" format:@"Color value %@ is invalid.  It should be a hex value of the form #RRGGBB, or #AARRGGBB", hexString];
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"0%@", substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)UIImage:(NSDictionary *)json {
    return [RCTConvert UIImage:json];
}

+ (BOOL)isIphoneX {
	UIWindow *window = RCTKeyWindow();
    return window.safeAreaInsets.bottom > 0.0;
}

@end
