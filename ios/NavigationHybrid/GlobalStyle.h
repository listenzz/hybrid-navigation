//
//  GlobalStyle.h
//  NavigationHybrid
//
//  Created by Listen on 2018/2/8.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalStyle : NSObject

@property (nonatomic, strong, readonly) UIColor *screenBackgroundColor;

@property (nonatomic, assign, readonly, getter=isBackTitleHidden) BOOL backTitleHidden;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (void)inflateNavigationBar:(UINavigationBar *)navigationBar;

- (void)inflateBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)inflateTabBar:(UITabBar *)tabBar;

@end
