//
//  GlobalStyle.h
//  HybridNavigation
//
//  Created by Listen on 2018/2/8.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalStyle : NSObject

@property(nonatomic, strong, readonly) UIColor *screenBackgroundColor;

@property(nonatomic, assign, readonly, getter=isBackTitleHidden) BOOL backTitleHidden;

@property(nonatomic, copy) NSString *badgeColorHexString;
@property(nonatomic, copy) NSString *tabBarItemColorHexString;
@property(nonatomic, copy) NSString *tabBarUnselectedItemColorHexString;
@property(nonatomic, strong, readonly) UIColor *tabBarBackgroundColor;
@property(nonatomic, assign, readonly) BOOL alwaysSplitNavigationBarTransition;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (void)inflateNavigationBar:(UINavigationBar *)navigationBar;

- (void)inflateBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)inflateTabBar:(UITabBar *)tabBar;

- (UIColor *)titleTextColorWithBarStyle:(UIBarStyle)barStyle;

- (UIColor *)tintColorWithBarStyle:(UIBarStyle)barStyle;

- (UIColor *)barTintColorWithBarStyle:(UIBarStyle)barStyle;

@end
