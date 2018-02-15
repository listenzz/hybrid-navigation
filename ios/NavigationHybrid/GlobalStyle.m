//
//  GlobalStyle.m
//  NavigationHybrid
//
//  Created by Listen on 2018/2/8.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "GlobalStyle.h"
#import "HBDUtils.h"

@interface GlobalStyle ()

@property (nonatomic, copy, readonly) NSDictionary *options;

@end

@implementation GlobalStyle

- (instancetype)initWithOptions:(NSDictionary *)options {
    if (self = [super init]) {
        _options = options;
        
        // screenBackgroundColor
        NSString *screenBackgroundColor = options[@"screenBackgroundColor"];
        if (screenBackgroundColor) {
            _screenBackgroundColor = [HBDUtils colorWithHexString:screenBackgroundColor];
        } else {
            _screenBackgroundColor = UIColor.whiteColor;
        }
        
        // hideBackTitle
        NSNumber *hideBackTitle = options[@"hideBackTitle"];
        if (hideBackTitle) {
            _backTitleHidden = [hideBackTitle boolValue];
        }
        
    }
    return self;
}

- (void)inflateNavigationBar:(UINavigationBar *)navigationBar {
    NSString *topBarStyle = self.options[@"topBarStyle"];
    BOOL isLightContentStyle = [topBarStyle isEqualToString:@"light-content"];
    
    // topBarStyle
    if (topBarStyle) {
        if ([topBarStyle isEqualToString:@"light-content"]) {
            [navigationBar setBarStyle:UIBarStyleBlack];
        } else {
            [navigationBar setBarStyle:UIBarStyleDefault];
        }
    }
    
    // topBarBackgroundColor
    NSString *topBarBackgroundColor = self.options[@"topBarBackgroundColor"];
    if (topBarBackgroundColor) {
        [self setNavigationBar:navigationBar backgroundColor:topBarBackgroundColor];
    } else {
        if (isLightContentStyle) {
            [self setNavigationBar:navigationBar backgroundColor:@"#000000"];
        } else {
            [self setNavigationBar:navigationBar backgroundColor:@"ffffff"];
        }
    }
    
    // shadowImeage
    NSDictionary *shadowImeage = self.options[@"shadowImage"];
    if (shadowImeage && ![shadowImeage isEqual:NSNull.null]) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = shadowImeage[@"image"];
        NSString *color = shadowImeage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        [navigationBar setShadowImage:image];
    }
    
    // backIcon
    NSDictionary *backIcon = self.options[@"backIcon"];
    if (backIcon) {
        UIImage *image = [HBDUtils UIImage:backIcon];
        [navigationBar setBackIndicatorTransitionMaskImage:image];
        [navigationBar setBackIndicatorImage:image];
    }
    
    // titleTextColor, titleTextSize
    NSString *titleTextColor = self.options[@"titleTextColor"];
    NSNumber *titleTextSize = self.options[@"titleTextSize"];
    NSString *topBarTintColor = self.options[@"topBarTintColor"];
    
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
    
    [navigationBar setTitleTextAttributes:titleAttributes];
}

- (void)inflateBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // topBarTintColor, barButtonItemTintColor, barButtonItemTextSize
    NSString *barButtonItemTintColor = self.options[@"barButtonItemTintColor"];
    NSNumber *barButtonItemTextSize = self.options[@"barButtonItemTextSize"];
    NSString *topBarStyle = self.options[@"topBarStyle"];
    NSString *topBarTintColor = self.options[@"topBarTintColor"];
    
    BOOL isLightContentStyle = [topBarStyle isEqualToString:@"light-content"];
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
    
    [barButtonItem setTintColor:itemTintColor];
    
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
    
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [barButtonItem setTitleTextAttributes:disabled forState:UIControlStateDisabled];
}

- (void)inflateTabBar:(UITabBar *)tabBar {
    // bottomBarBackgroundColor
    NSString *bottomBarBackgroundColor = self.options[@"bottomBarBackgroundColor"];
    if (bottomBarBackgroundColor) {
        UIColor *color = [HBDUtils colorWithHexString:bottomBarBackgroundColor];
        [tabBar setBackgroundImage:[HBDUtils imageWithColor:color]];
    }
    
    // shadowImeage
    NSDictionary *bottomBarShadowImage = self.options[@"bottomBarShadowImage"];
    if (bottomBarShadowImage && ![bottomBarShadowImage isEqual:NSNull.null]) {
        UIImage *image = [UIImage new];
        NSDictionary *imageItem = bottomBarShadowImage[@"image"];
        NSString *color = bottomBarShadowImage[@"color"];
        if (imageItem) {
            image = [HBDUtils UIImage:imageItem];
        } else if (color) {
            image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
        }
        [tabBar setShadowImage:image];
    }
    
    // tabBar tintColor
    NSString *bottomBarButtonItemActiveColor = self.options[@"bottomBarButtonItemActiveColor"];
    if (bottomBarButtonItemActiveColor) {
        [tabBar setTintColor:[HBDUtils colorWithHexString:bottomBarButtonItemActiveColor]];
    }
    
    NSString *bottomBarButtonItemInActiveColor = self.options[@"bottomBarButtonItemInActiveColor"];
    if (bottomBarButtonItemInActiveColor) {
        if (@available(iOS 10.0, *)) {
            [tabBar setUnselectedItemTintColor:[HBDUtils colorWithHexString:bottomBarButtonItemInActiveColor]];
        }
    }
    
}

- (void)setNavigationBar:(UINavigationBar *)bar backgroundColor:(NSString *)color {
    UIColor *c = [HBDUtils colorWithHexString:color];
    [bar setBackgroundImage:[HBDUtils imageWithColor:c] forBarMetrics:UIBarMetricsDefault];
}

@end
