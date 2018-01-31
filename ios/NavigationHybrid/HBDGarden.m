//
//  HBDGarden.m
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
static UIColor *screenBackgroundColor;
static NSDictionary *globalStyle;

+ (void)setStyle:(NSDictionary *)style {
    globalStyle = style;
    // screenBackgroundColor
    
    NSString *screenBackgroundColor = style[@"screenBackgroundColor"];
    if (screenBackgroundColor) {
        [self setScreenBackgroundColor:screenBackgroundColor];
    }
    
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
    
    // titleTextColor, titleTextSize
    NSString *titleTextColor = style[@"titleTextColor"];
    NSNumber *titleTextSize = style[@"titleTextSize"];
    NSString *topBarTintColor = style[@"topBarTintColor"];
    
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
    
    // topBarTintColor, barButtonItemTintColor, barButtonItemTextSize
    NSString *barButtonItemTintColor = style[@"barButtonItemTintColor"];
    NSNumber *barButtonItemTextSize = style[@"barButtonItemTextSize"];
    
    UIColor *itemTintColor;
    
    if (barButtonItemTintColor) {
        itemTintColor = [HBDUtils colorWithHexString:barButtonItemTintColor];
    } else if (topBarTintColor){
        itemTintColor = [HBDUtils colorWithHexString:topBarTintColor];
    } else {
        if (isLightContentStyle) {
            itemTintColor = UIColor.whiteColor;
        } else {
            itemTintColor = UIColor.blackColor;
        }
    }
    
    [[UIBarButtonItem appearance] setTintColor:itemTintColor];

    NSInteger fontSize = 15;
    if (barButtonItemTextSize) {
        fontSize = [barButtonItemTextSize integerValue];
    }
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                 };
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    [itemTintColor getRed:&red green:&green blue:&blue alpha:nil];
    
    CGFloat gray = MAX(MAX(red, green), blue);
    UIColor *disabledColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:0.3];
   
    NSDictionary *disabled = @{
                               NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                               NSForegroundColorAttributeName: disabledColor,
                               };
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabled forState:UIControlStateDisabled];
    
    // tabBar

    // bottomBarBackgroundColor
    NSString *bottomBarBackgroundColor = style[@"bottomBarBackgroundColor"];
    if (bottomBarBackgroundColor) {
        [self setBottomBarBackgroundColor:bottomBarBackgroundColor];
    }
   
    // shadowImeage
    NSDictionary *bottomBarShadowImage = style[@"bottomBarShadowImage"];
    if (bottomBarShadowImage && ![bottomBarShadowImage isEqual:NSNull.null]) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = bottomBarShadowImage[@"image"];
        NSString *color = bottomBarShadowImage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        [[UITabBar appearance] setShadowImage:image];
    }
    
    // tabBar tintColor
    NSString *bottomBarButtonItemTintColor = style[@"bottomBarButtonItemTintColor"];
    if (bottomBarButtonItemTintColor) {
        [[UITabBar appearance] setTintColor:[HBDUtils colorWithHexString:bottomBarButtonItemTintColor]];
    }
    
}

+ (NSDictionary *)globalStyle {
    return globalStyle;
}

+ (void)setScreenBackgroundColor:(NSString *)color {
    screenBackgroundColor = [HBDUtils colorWithHexString:color];
}

+ (UIColor *)screenBackgroundColor {
    if (!screenBackgroundColor) {
        screenBackgroundColor = UIColor.whiteColor;
    }
    return screenBackgroundColor;
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

+ (void)setBottomBarBackgroundColor:(NSString *)color {
    UIColor *c = [HBDUtils colorWithHexString:color];
    [[UITabBar appearance] setBackgroundImage:[HBDUtils imageWithColor:c]];
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
    
    NSDictionary *insetsOption = item[@"insets"];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (insetsOption) {
        insets =  [RCTConvert UIEdgeInsets:insetsOption];
    }

    NSDictionary *icon = item[@"icon"];
    BOOL hasIcon = icon && ![icon isEqual:NSNull.null];
    if (hasIcon) {
        UIImage *iconImage = [HBDUtils UIImage:icon];
        barButtonItem = [[HBDBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain];
        barButtonItem.imageInsets = insets;
    } else {
        NSString *title = item[@"title"];
        barButtonItem = [[HBDBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain];
        [barButtonItem setTitlePositionAdjustment:UIOffsetMake(insets.left, 0) forBarMetrics:UIBarMetricsDefault];
    }
    
    NSNumber *enabled = item[@"enabled"];
    if (enabled) {
        barButtonItem.enabled = [enabled boolValue];
    }
    
    NSString *action = item[@"action"];
    NSString *sceneId = controller.sceneId;
    if (action) {
        barButtonItem.actionBlock = ^{
            RCTEventEmitter *emitter = [[HBDReactBridgeManager instance].bridge moduleForName:@"NavigationHybrid"];
            [emitter sendEventWithName:@"ON_BAR_BUTTON_ITEM_CLICK" body:@{
                                                                             @"action": action,
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

