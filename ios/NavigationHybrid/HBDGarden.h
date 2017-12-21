//
//  HBDGarden.h
//  Pods
//
//  Created by Listen on 2017/11/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HBDViewController.h"

@interface HBDGarden : NSObject

+ (void)setTopBarStyle:(NSString *)style;

+ (void)setHideBackTitle:(BOOL)hidden;

+ (BOOL)isBackTitleHidden;

+ (void)setBackIcon:(NSDictionary *)icon;

+ (void)setTopBarBackgroundColor:(NSString *)color;

+ (void)setTopBarTintColor:(NSString *)color;

+ (void)setTitleTextColor:(NSString *)color;

+ (void)setTitleTextSize:(NSUInteger)dp;

+ (void)setBarButtonItemTintColor:(NSString *)color;

+ (void)setBarButtonItemTextSize:(NSUInteger)dp;

// ------

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setHidesBackButton:(BOOL)hidden forController:(HBDViewController *)controller;

@end
