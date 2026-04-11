#import "GlobalStyle.h"

#import "HBDUtils.h"

@interface GlobalStyle ()

@property(nonatomic, copy, readonly) NSDictionary *options;
@property(nonatomic, assign, readwrite) UIBarStyle statusBarStyle;

@property(nonatomic, strong) UIColor *tabBarBackgroundColor;
@property(nonatomic, strong) UIImage *tabBarShadowImage;
@property(nonatomic, strong) UIColor *tabBarItemSelectedColor;
@property(nonatomic, strong) UIColor *tabBarItemNormalColor;

@end

@implementation GlobalStyle

static GlobalStyle *globalStyle;

+ (void)createWithOptions:(NSDictionary *)options {
    globalStyle = [[GlobalStyle alloc] initWithOptions:options];
    [globalStyle inflateTabBar:[UITabBar appearance]];
}

+ (GlobalStyle *)globalStyle {
    if (!globalStyle) {
        [self createWithOptions:@{}];
    }
    return globalStyle;
}

- (instancetype)initWithOptions:(NSDictionary *)options {
    if (self = [super init]) {
        _options = options;
        _interfaceOrientation = UIInterfaceOrientationMaskPortrait;

        NSString *screenBackgroundColor = options[@"screenBackgroundColor"];
        if (screenBackgroundColor) {
            _screenBackgroundColor = [HBDUtils colorWithHexString:screenBackgroundColor];
        } else {
            _screenBackgroundColor = UIColor.whiteColor;
        }

        NSString *statusBarStyle = options[@"statusBarStyle"];
        if (statusBarStyle && [statusBarStyle isEqualToString:@"light-content"]) {
            _statusBarStyle = UIBarStyleBlack;
        } else {
            _statusBarStyle = UIBarStyleDefault;
        }

        NSString *tabBarBackgroundColor = options[@"tabBarBackgroundColor"];
        if (!tabBarBackgroundColor) {
            tabBarBackgroundColor = @"#FFFFFF";
        }
        self.tabBarBackgroundColor = [HBDUtils colorWithHexString:tabBarBackgroundColor];

        NSDictionary *tabBarShadowImage = options[@"tabBarShadowImage"];
        if ([tabBarShadowImage isKindOfClass:[NSDictionary class]]) {
            UIImage *image = [UIImage new];
            NSDictionary *imageItem = tabBarShadowImage[@"image"];
            NSString *color = tabBarShadowImage[@"color"];
            if ([imageItem isKindOfClass:[NSDictionary class]]) {
                image = [HBDUtils UIImage:imageItem];
            } else if ([color isKindOfClass:[NSString class]]) {
                image = [HBDUtils imageWithColor:[HBDUtils colorWithHexString:color]];
            }
            self.tabBarShadowImage = image;
        }

        NSString *tabBarItemSelectedColor = options[@"tabBarItemSelectedColor"];
        NSString *tabBarItemNormalColor = options[@"tabBarItemNormalColor"];
        if (!tabBarItemSelectedColor) {
            tabBarItemSelectedColor = @"#FF5722";
        }
        if (!tabBarItemNormalColor) {
            tabBarItemNormalColor = @"#666666";
        }
        self.tabBarItemSelectedColor = [HBDUtils colorWithHexString:tabBarItemSelectedColor];
        self.tabBarItemNormalColor = [HBDUtils colorWithHexString:tabBarItemNormalColor];

        NSString *tabBarBadgeColor = options[@"tabBarBadgeColor"];
        if (!tabBarBadgeColor) {
            tabBarBadgeColor = @"#FF3B30";
        }
        [UITabBarItem appearance].badgeColor = [HBDUtils colorWithHexString:tabBarBadgeColor];
    }
    return self;
}

- (void)inflateTabBar:(UITabBar *)tabBar {
    UITabBarItemAppearance *tabBarItem = [UITabBarItemAppearance new];
    tabBarItem.normal.titleTextAttributes = @{
        NSForegroundColorAttributeName: self.tabBarItemNormalColor,
    };
    tabBarItem.normal.iconColor = self.tabBarItemNormalColor;
    tabBarItem.selected.titleTextAttributes = @{
        NSForegroundColorAttributeName: self.tabBarItemSelectedColor,
    };
    tabBarItem.selected.iconColor = self.tabBarItemSelectedColor;

    UITabBarAppearance *tabBarAppearance = [UITabBarAppearance new];
    [tabBarAppearance configureWithDefaultBackground];

    tabBarAppearance.shadowImage = self.tabBarShadowImage;
    tabBarAppearance.stackedLayoutAppearance = tabBarItem;

    tabBar.scrollEdgeAppearance = tabBarAppearance;
    tabBar.standardAppearance = tabBarAppearance;

    if (self.tabBarBackgroundColor) {
        if (@available(iOS 26.0, *)) {
            //
        } else {
            tabBar.standardAppearance.backgroundImage = [HBDUtils imageWithColor:self.tabBarBackgroundColor];
        }
    }

    if (self.tabBarShadowImage) {
        [tabBar setShadowImage:self.tabBarShadowImage];
    }
}

@end
