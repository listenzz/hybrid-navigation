//
//  HBDUtils.m
//  NavigationHybrid
//
//  Created by Listen on 2017/12/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDUtils.h"
#import <React/RCTConvert.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@implementation HBDUtils

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target {
    NSMutableDictionary *mutableTarget = [target mutableCopy];
    for (NSString *key in [item allKeys]) {
        id obj = [item objectForKey:key];
        if (obj == nil) {
            //ignore
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *subTarget = [target objectForKey:key];
            if (RCTNilIfNull(subTarget)) {
                [mutableTarget setObject:[self mergeItem:obj withTarget:subTarget] forKey:key];
            } else {
                [mutableTarget setObject:obj forKey:key];
            }
        } else {
            [mutableTarget setObject:obj forKey:key];
        }
    }
    
    return [mutableTarget copy];
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, green, blue;
    switch ([colorString length]) {
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            alpha = 1.0f;
            red   = 0.0f;
            green = 0.0f;
            blue  = 0.0f;
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"0%@", substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)UIImage:(NSDictionary *)json {
    if ([json isKindOfClass:[NSDictionary class]]) {
         NSString *uri = json[@"uri"];
        if (uri && [uri hasPrefix:@"font:"]) {
            NSString *path = [self imagePathFromFontUri:uri];
            // RCTLogInfo(@"font path:%@", path);
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            return image;
        }  else {
            return [RCTConvert UIImage:json];
        }
    } else {
        return [RCTConvert UIImage:json];
    }
    return nil;
}

+ (NSString *)iconUriFromUri:(NSString *)uri {
    if ([uri hasPrefix:@"font:"]) {
        return [self imagePathFromFontUri:uri];
    }
    return uri;
}

+ (NSString *)imagePathFromFontUri:(NSString *)uri {
    uri = [uri substringFromIndex:7];
    // RCTLogInfo(@"font uri:%@", uri);
    NSArray *components = [uri componentsSeparatedByString:@"/"];
    if (components.count < 3) {
        return nil;
    }
    NSString *font = components[0];
    NSString *glyph = components[1];
    CGFloat size = [components[2] floatValue];
    UIColor *color = UIColor.whiteColor;
    if (components.count >=4) {
        color = [self colorWithHexString:components[3]];
    }
    NSString *path = [self imagePathForFont:font withGlyph:glyph withFontSize:size withColor:color];
    return path;
}

+ (NSString *)imagePathForFont:(NSString*)fontName withGlyph:(NSString*)glyph withFontSize:(CGFloat)fontSize withColor:(UIColor *)color {
    CGFloat screenScale = RCTScreenScale();
    
    NSString *hexColor = [self hexStringFromColor:color];
    
    NSString *fileName = [NSString stringWithFormat:@"tmp/RNVectorIcons_%@_%hu_%.f%@@%.fx.png", fontName, [glyph characterAtIndex:0], fontSize, hexColor, screenScale];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // No cached icon exists, we need to create it and persist to disk
        
        UIFont *font = [UIFont fontWithName:fontName size:fontSize];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:glyph attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}];
        
        CGSize iconSize = [attributedString size];
        UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
        [attributedString drawAtPoint:CGPointMake(0, 0)];
        
        UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(iconImage);
        BOOL success = [imageData writeToFile:filePath atomically:YES];
        if(!success) {
            RCTLogInfo(@"can't save %@", fileName);
            return nil;
        }
    }
    return filePath;
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+ (BOOL)isIphoneX {
    return @available(iOS 11.0, *) && UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0;
}

+ (BOOL)isInCall {
    if ([HBDUtils isIphoneX]) {
        CTCallCenter *callCenter = [[CTCallCenter alloc] init] ;
        for (CTCall *call in callCenter.currentCalls)  {
            if (call.callState == CTCallStateConnected) {
                return YES;
            }
        }
        return NO;
    } else {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        return statusBarHeight == 40;
    }
}

@end
