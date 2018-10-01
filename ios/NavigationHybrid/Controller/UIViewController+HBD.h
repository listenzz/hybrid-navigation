//
//  UIViewController+HBD.h
//  NavigationHybrid
//
//  Created by Listen on 2018/1/22.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBDDrawerController.h"

@interface UIViewController (HBD)

@property(nonatomic, copy, readonly) NSString *sceneId;

@property (nonatomic, assign) UIBarStyle hbd_barStyle;
@property (nonatomic, strong) UIColor *hbd_barTintColor;
@property (nonatomic, strong) UIColor *hbd_tintColor;
@property (nonatomic, strong) NSDictionary *hbd_titleTextAttributes;
@property (nonatomic, assign) float hbd_barAlpha;
@property (nonatomic, assign) BOOL hbd_barHidden;
@property (nonatomic, assign) BOOL hbd_barShadowHidden;
@property (nonatomic, assign) BOOL hbd_backInteractive;
@property (nonatomic, assign) BOOL hbd_swipeBackEnabled;
@property (nonatomic, assign) BOOL hbd_extendedLayoutIncludesTopBar;

@property (nonatomic, assign, readonly) float hbd_barShadowAlpha;

- (void)hbd_setNeedsUpdateNavigationBar;
- (void)hbd_setNeedsUpdateNavigationBarAlpha;
- (void)hbd_setNeedsUpdateNavigationBarColor;
- (void)hbd_setNeedsUpdateNavigationBarShadowImageAlpha;

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data;

- (NSInteger)resultCode;

- (NSDictionary *)resultData;

- (void)setRequestCode:(NSInteger)requestCode;

- (NSInteger)requestCode;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

- (HBDDrawerController *)drawerController;

- (void)hbd_updateTabBarItem:(NSDictionary *)options;

- (NSString *)hbd_mode;

@end
