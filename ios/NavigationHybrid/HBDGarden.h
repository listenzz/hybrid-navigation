//
//  HBDGarden.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController/HBDViewController.h"
#import "GlobalStyle.h"

@interface HBDGarden : NSObject

+ (void)createGlobalStyleWithOptions:(NSDictionary *)options;

+ (GlobalStyle *)globalStyle;

// ------

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setLeftBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller;

- (void)setRightBarButtonItems:(NSArray *)items forController:(HBDViewController *)controller;

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setStatusBarHidden:(BOOL)hidden forController:(HBDViewController *)controller;

- (void)setPassThroughTouches:(BOOL)passThrough forController:(HBDViewController *)controller;


@end
