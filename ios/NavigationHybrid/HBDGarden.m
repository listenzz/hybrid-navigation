//
//  HBDGarden.m
//  Pods
//
//  Created by Listen on 2017/11/26.
//

#import "HBDGarden.h"
#import <React/RCTConvert.h>
#import <React/RCTEventEmitter.h>

#import "HBDBarButtonItem.h"
#import "HBDReactBridgeManager.h"

@implementation HBDGarden

static bool backTitleHidden = NO;

+ (void)setStyle:(NSDictionary *)style {
    // topBarStyle
    NSString *topBarStyle = style[@"topBarStyle"];
    if (topBarStyle) {
        [self setTopBarStyle:topBarStyle];
    }
    
    // topBarBackgroundColor
    NSString *topBarBackgroundColor = style[@"topBarBackgroundColor"];
    if (topBarBackgroundColor) {
        [self setTopBarBackgroundColor:topBarBackgroundColor];
    }
    
    // hideBackTitle
    NSNumber *hideBackTitle = style[@"hideBackTitle"];
    if (hideBackTitle) {
        [self setHideBackTitle:[hideBackTitle boolValue]];
    }
    
    // backIcon
    NSDictionary *backIcon = style[@"backIcon"];
    if (backIcon) {
        [self setBackIcon:backIcon];
    }
    
    // topBarTintColor
    NSString *topBarTintColor = style[@"topBarTintColor"];
    if (topBarTintColor) {
        [self setTopBarTintColor:topBarTintColor];
    } else {
        if ([topBarStyle isEqualToString:@"light-content"]) {
            [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        } else {
            [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
        }
    }
    
    // titleTextColor, titleTextSize
    NSString *titleTextColor = style[@"titleTextColor"];
    NSNumber *titleTextSize = style[@"titleTextSize"];
    NSMutableDictionary *titleAttributes = [[NSMutableDictionary alloc] init];
    
    if (titleTextColor) {
        [titleAttributes setObject:[self colorWithHexString:titleTextColor] forKey:NSForegroundColorAttributeName];
    } else {
        if (topBarTintColor) {
            [titleAttributes setObject:[self colorWithHexString:topBarTintColor] forKey:NSForegroundColorAttributeName];
        } else {
            if ([topBarStyle isEqualToString:@"light-content"]) {
                [titleAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            } else {
                [titleAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
            }
        }
    }
    
    if (titleTextSize) {
        [titleAttributes setObject:[UIFont systemFontOfSize:[titleTextSize floatValue]] forKey:NSFontAttributeName];
    } else {
         [titleAttributes setObject:[UIFont systemFontOfSize:17.0] forKey:NSFontAttributeName];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    // barButtonItemTintColor, barButtonItemTextSize
    NSString *barButtonItemTintColor = style[@"barButtonItemTintColor"];
    if (barButtonItemTintColor) {
        [self setBarButtonItemTintColor:barButtonItemTintColor];
    }
}

+ (void)setHideBackTitle:(BOOL)hidden {
    backTitleHidden = hidden;
}

+ (BOOL)isBackTitleHidden {
    return backTitleHidden;
}

+ (void)setTopBarStyle:(NSString *)style {
    if ([style isEqualToString:@"light-content"]) {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    } else {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    }
}

+ (void)setBackIcon:(NSDictionary *)icon {
    UIImage *backIcon = [HBDGarden UIImage:icon];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backIcon];
    [[UINavigationBar appearance] setBackIndicatorImage:backIcon];
}

+ (void)setTopBarBackgroundColor:(NSString *)color {
    UIColor *c = [self colorWithHexString:color];
    [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:c] forBarMetrics:UIBarMetricsDefault];
}

+ (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 8.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (void)setTopBarTintColor:(NSString *)color {
    UIColor *c = [self colorWithHexString:color];
    [[UINavigationBar appearance] setTintColor:c];
}

+ (void)setBarButtonItemTintColor:(NSString *)color {
    UIColor *c = [self colorWithHexString:color];
    [[UIBarButtonItem appearance] setTintColor:c];
}

+ (void)setBarButtonItemTextSize:(NSUInteger)dp {
    
}

+ (UIImage *)UIImage:(NSDictionary *)json {
    NSString *uri = json[@"uri"];
    if (uri && [uri hasPrefix:@"font:"]) {
        uri = [uri substringFromIndex:7];
        NSLog(@"font uri:%@", uri);
        NSArray *components = [uri componentsSeparatedByString:@"/"];
        if (components.count != 3) {
            return nil;
        }
        NSString *font = components[0];
        NSString *glyph = components[1];
        CGFloat size = [components[2] floatValue];
        NSString *path = [self imagePathForFont:font withGlyph:glyph withFontSize:size withColor:[UIColor whiteColor]];
        NSLog(@"font path:%@", path);
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        return image;
    } else {
        return [RCTConvert UIImage:json];
    }
    return nil;
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
            NSLog(@"can't save %@", fileName);
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

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, green, blue;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 5: // #RRGGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 1];
            break;
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
        case 0:
            alpha = 1.0f;
            red   = 0.0f;
            green = 0.0f;
            blue  = 0.0f;
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

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"0%@", substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        controller.navigationItem.leftBarButtonItem = [self createBarButtonItem:item forController:controller];
    } else {
        controller.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        controller.navigationItem.rightBarButtonItem = [self createBarButtonItem:item forController:controller];
    } else {
        controller.navigationItem.rightBarButtonItem = nil;
    }
}

- (HBDBarButtonItem *)createBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    HBDBarButtonItem *barButtonItem;
    NSDictionary *icon = item[@"icon"];
    if (icon) {
        UIImage *iconImage = [HBDGarden UIImage:icon];
        barButtonItem = [[HBDBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain];
    } else {
        NSString *title = item[@"title"];
        barButtonItem = [[HBDBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain];
    }
    
    NSString *action = item[@"action"];
    NSString *navId = controller.navigator.navId;
    NSString *sceneId = controller.sceneId;
    if (action) {
        barButtonItem.actionBlock = ^{
            RCTEventEmitter *emitter = [[HBDReactBridgeManager instance].bridge moduleForName:@"NavigationHybrid"];
            [emitter sendEventWithName:ON_BAR_BUTTON_ITEM_CLICK_EVENT body:@{
                                                                             @"action": action,
                                                                             @"navId": navId,
                                                                             @"sceneId": sceneId
                                                                             }];
        };
    }
    return barButtonItem;
}

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        NSString *title = item[@"title"];
        controller.navigationItem.title = title;
    } else {
        controller.navigationItem.title = nil;
    }
}

- (void)setHidesBackButton:(BOOL)hidden forController:(HBDViewController *)controller {
    controller.navigationItem.hidesBackButton = hidden;
}

@end

