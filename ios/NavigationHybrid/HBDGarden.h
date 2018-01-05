//
//  HBDGarden.h
//
//  Created by Listen on 2017/11/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HBDViewController.h"

@interface HBDGarden : NSObject

+ (void)setStyle:(NSDictionary *)style;

+ (BOOL)isBackTitleHidden;

+ (UIColor *)screenBackgroundColor;

+ (NSDictionary *)globalStyle;

// ------

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setHideBackButton:(BOOL)hidden forController:(HBDViewController *)controller;

@end
