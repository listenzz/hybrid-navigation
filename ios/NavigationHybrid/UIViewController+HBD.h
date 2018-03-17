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

@property (nonatomic, strong) UIColor *topBarColor;
@property (nonatomic, assign) float topBarAlpha;
@property (nonatomic, assign) BOOL topBarHidden;
@property (nonatomic, assign) float topBarShadowAlpha;
@property (nonatomic, assign) BOOL topBarShadowHidden;
@property (nonatomic, assign) BOOL backInteractive;

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data;

- (NSInteger)resultCode;

- (NSDictionary *)resultData;

- (void)setRequestCode:(NSInteger)requestCode;

- (NSInteger)requestCode;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

- (HBDDrawerController *)drawerController;

@end
