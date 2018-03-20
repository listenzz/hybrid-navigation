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

@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, strong) UIImage *shadowImage;
@property (nonatomic, strong) UIImage *backIcon;
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *barButtonItemTintColor;
@property (nonatomic, assign) NSInteger titleTextSize;
@property (nonatomic, assign) NSInteger barButtonItemTextSize;

@property (nonatomic, strong) UIColor *tabBarBarTintColor;
@property (nonatomic, strong) UIImage *tabBarShadowImage;
@property (nonatomic, strong) UIColor *tabBarTintColor;
@property (nonatomic, strong) UIColor *tabBarUnselectedTintColor;

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
        
        NSString *topBarStyle = self.options[@"topBarStyle"];
        if (topBarStyle && [topBarStyle isEqualToString:@"light-content"]) {
            self.barStyle = UIBarStyleBlack;
            self.barTintColor = UIColor.blackColor;
            self.tintColor = UIColor.whiteColor;
            self.barButtonItemTintColor = UIColor.whiteColor;
            self.titleTextColor = UIColor.whiteColor;
        } else {
            self.barStyle = UIBarStyleDefault;
            self.barTintColor = UIColor.whiteColor;
            self.tintColor = UIColor.blackColor;
            self.barButtonItemTintColor = UIColor.blackColor;
            self.titleTextColor = UIColor.blackColor;
        }
        
        // topBarBackgroundColor
        NSString *topBarColor = self.options[@"topBarColor"];
        if (topBarColor) {
            self.barTintColor = [HBDUtils colorWithHexString:topBarColor];
        }
        
        // navigationBar shadowImeage
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
            self.shadowImage = image;
        }

        // hideBackTitle
        NSNumber *hideBackTitle = options[@"hideBackTitle"];
        if (hideBackTitle) {
            _backTitleHidden = [hideBackTitle boolValue];
        }
        
        // backIcon
        NSDictionary *backIcon = self.options[@"backIcon"];
        if (backIcon) {
            self.backIcon = [HBDUtils UIImage:backIcon];
        }
        
        // topBarTintColor,
        NSString *topBarTintColor = self.options[@"topBarTintColor"];
        if (topBarTintColor) {
            self.tintColor = [HBDUtils colorWithHexString:topBarTintColor];
            self.barButtonItemTintColor = self.tintColor;
            self.titleTextColor = self.tintColor;
        }
        
        // titleTextColor,
         NSString *titleTextColor = self.options[@"titleTextColor"];
        if (titleTextColor) {
            self.titleTextColor = [HBDUtils colorWithHexString:titleTextColor];
        }
        
        // titleTextSize
        NSNumber *titleTextSize = self.options[@"titleTextSize"];
        if (titleTextSize) {
            self.titleTextSize = [titleTextSize integerValue];
        } else {
            self.titleTextSize = 17;
        }

        NSString *barButtonItemTintColor = self.options[@"barButtonItemTintColor"];
        if (barButtonItemTintColor) {
            self.barButtonItemTintColor = [HBDUtils colorWithHexString:barButtonItemTintColor];
        }
        
        NSNumber *barButtonItemTextSize = self.options[@"barButtonItemTextSize"];
        if (barButtonItemTextSize) {
            self.barButtonItemTextSize = [barButtonItemTextSize integerValue];
        } else {
            self.barButtonItemTextSize = 15;
        }
        
        // tabBarColor
        NSString *tabBarColor = self.options[@"bottomBarColor"];
        if (tabBarColor) {
            self.tabBarBarTintColor = [HBDUtils colorWithHexString:tabBarColor];
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
            self.tabBarShadowImage = image;
        }
        
        // tabBar tintColor
        NSString *bottomBarButtonItemActiveColor = self.options[@"bottomBarButtonItemActiveColor"];
        if (bottomBarButtonItemActiveColor) {
            self.tabBarTintColor = [HBDUtils colorWithHexString:bottomBarButtonItemActiveColor];
        }
        
        NSString *bottomBarButtonItemInactiveColor = self.options[@"bottomBarButtonItemInactiveColor"];
        if (bottomBarButtonItemInactiveColor) {
            self.tabBarUnselectedTintColor = [HBDUtils colorWithHexString:bottomBarButtonItemInactiveColor];
        }
        
    }
    return self;
}

- (void)inflateNavigationBar:(UINavigationBar *)navigationBar {
    
    [navigationBar setBarStyle:self.barStyle];
    [navigationBar setBarTintColor:self.barTintColor];
    
    if (self.shadowImage) {
        [navigationBar setShadowImage:self.shadowImage];
    }
    
    if (self.backIcon) {
        [navigationBar setBackIndicatorImage:self.backIcon];
        [navigationBar setBackIndicatorTransitionMaskImage:self.backIcon];
    }
    
    [navigationBar setTintColor:self.tintColor];
    
    // title
    NSMutableDictionary *titleAttributes = [[NSMutableDictionary alloc] init];
    [titleAttributes setObject:self.titleTextColor forKey:NSForegroundColorAttributeName];
    [titleAttributes setObject:[UIFont systemFontOfSize:self.titleTextSize] forKey:NSFontAttributeName];
    [navigationBar setTitleTextAttributes:titleAttributes];
}

- (void)inflateBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [barButtonItem setTintColor:self.barButtonItemTintColor];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:self.barButtonItemTextSize],
                                 NSForegroundColorAttributeName: self.barButtonItemTintColor
                                 };
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
}

- (void)inflateTabBar:(UITabBar *)tabBar {
    if (self.tabBarBarTintColor) {
        [tabBar setBackgroundImage:[HBDUtils imageWithColor:self.tabBarBarTintColor]];
    }
    
    if (self.tabBarShadowImage) {
         [tabBar setShadowImage:self.tabBarShadowImage];
    }
    
    if (self.tabBarTintColor) {
        [tabBar setTintColor:self.tabBarTintColor];
    }

    if (@available(iOS 10.0, *)) {
        if (self.tabBarUnselectedTintColor) {
            [tabBar setUnselectedItemTintColor:self.tabBarUnselectedTintColor];
        }
    }
}

@end
