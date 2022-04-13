//
//  HBDGarden.h
//  HybridNavigation
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBDViewController.h"
#import "GlobalStyle.h"

@class HBDViewController;

@interface HBDGarden : NSObject

+ (void)createGlobalStyleWithOptions:(NSDictionary *)options;

+ (GlobalStyle *)globalStyle;

// ------

@property(nonatomic, assign) BOOL forceTransparentDialogWindow;

- (instancetype)initWithViewController:(HBDViewController *)vc;

- (void)setLeftBarButtonItem:(NSDictionary *)item;

- (void)setRightBarButtonItem:(NSDictionary *)item;

- (void)setLeftBarButtonItems:(NSArray *)items;

- (void)setRightBarButtonItems:(NSArray *)items;

- (void)setPassThroughTouches:(BOOL)passThrough;


@end
