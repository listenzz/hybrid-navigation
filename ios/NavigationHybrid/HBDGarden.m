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
#import "HBDUtils.h"

@implementation HBDGarden

static bool backTitleHidden = NO;

+ (void)setStyle:(NSDictionary *)style {
    // topBarStyle
    NSString *topBarStyle = style[@"topBarStyle"];
    BOOL isLightContentStyle = [topBarStyle isEqualToString:@"light-content"];
    
    if (topBarStyle) {
        [self setTopBarStyle:topBarStyle];
    }
    
    // topBarBackgroundColor
    NSString *topBarBackgroundColor = style[@"topBarBackgroundColor"];
    if (topBarBackgroundColor) {
        [self setTopBarBackgroundColor:topBarBackgroundColor];
    } else {
        if (isLightContentStyle) {
            [self setTopBarBackgroundColor:@"#000000"];
        } else {
            [self setTopBarBackgroundColor:@"#ffffff"];
        }
    }
    
    // shadowImeage
    NSDictionary *shadowImeage = style[@"shadowImage"];
    if (shadowImeage && ![shadowImeage isEqual:NSNull.null]) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = shadowImeage[@"image"];
        NSString *color = shadowImeage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        [[UINavigationBar appearance] setShadowImage:image];
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
        if (isLightContentStyle) {
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
        [titleAttributes setObject:[HBDUtils colorWithHexString:titleTextColor] forKey:NSForegroundColorAttributeName];
    } else {
        if (topBarTintColor) {
            [titleAttributes setObject:[HBDUtils colorWithHexString:topBarTintColor] forKey:NSForegroundColorAttributeName];
        } else {
            if (isLightContentStyle) {
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
    UIImage *backIcon = [HBDUtils UIImage:icon];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backIcon];
    [[UINavigationBar appearance] setBackIndicatorImage:backIcon];
}

+ (void)setTopBarBackgroundColor:(NSString *)color {
    UIColor *c = [HBDUtils colorWithHexString:color];
    [[UINavigationBar appearance] setBackgroundImage:[HBDUtils imageWithColor:c] forBarMetrics:UIBarMetricsDefault];
}

+ (void)setTopBarTintColor:(NSString *)color {
    UIColor *c = [HBDUtils colorWithHexString:color];
    [[UINavigationBar appearance] setTintColor:c];
}

+ (void)setBarButtonItemTintColor:(NSString *)color {
    UIColor *c = [HBDUtils colorWithHexString:color];
    [[UIBarButtonItem appearance] setTintColor:c];
}

+ (void)setBarButtonItemTextSize:(NSUInteger)dp {
    
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
    if (icon && ![icon isEqual:NSNull.null]) {
        UIImage *iconImage = [HBDUtils UIImage:icon];
        barButtonItem = [[HBDBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain];
    } else {
        NSString *title = item[@"title"];
        barButtonItem = [[HBDBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain];
    }
    
    NSNumber *enabled = item[@"enabled"];
    if (enabled) {
        barButtonItem.enabled = [enabled boolValue];
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

- (void)setHideBackButton:(BOOL)hidden forController:(HBDViewController *)controller {
    controller.navigationItem.hidesBackButton = hidden;
}

@end

