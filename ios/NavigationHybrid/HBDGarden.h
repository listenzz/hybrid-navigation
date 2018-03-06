//
//  HBDGarden.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBDViewController.h"
#import "GlobalStyle.h"

@interface HBDGarden : NSObject

+ (void)createGlobalStyleWithOptions:(NSDictionary *)options;

+ (GlobalStyle *)globalStyle;

// ------

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setTopBarStyle:(UIBarStyle)barStyle forController:(HBDViewController *)controller;

- (void)setTopBarAlpha:(float)alpha forController:(HBDViewController *)controller;

- (void)setTopBarColor:(UIColor *)color forController:(HBDViewController *)controller;

- (void)setTopBarShadowHidden:(BOOL)hidden forController:(HBDViewController *)controller;

@end
