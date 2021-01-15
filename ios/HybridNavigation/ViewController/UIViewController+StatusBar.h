//
//  UIViewController+StatusBar.h
//  NavigationHybrid
//
//  Created by Listen on 2018/8/29.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (StatusBar)

@property (nonatomic, assign) BOOL hbd_statusBarHidden;
@property (nonatomic, assign, readonly) BOOL hbd_inCall;

- (void)hbd_setNeedsStatusBarHiddenUpdate;

@end
