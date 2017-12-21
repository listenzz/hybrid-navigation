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
    UIColor *c = [RCTConvert UIColor:color];
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
    UIColor *c = [RCTConvert UIColor:color];
    [[UINavigationBar appearance] setTintColor:c];
}

+ (void)setTitleTextColor:(NSString *)color {
    
}

+ (void)setTitleTextSize:(NSUInteger)dp {
    
}

+ (void)setBarButtonItemTintColor:(NSString *)color {
    UIColor *c = [RCTConvert UIColor:color];
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
