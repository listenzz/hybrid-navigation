//
//  HBDGarden.h
//
//  Created by Listen on 2017/11/26.
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

- (void)setHideBackButton:(BOOL)hidden forController:(HBDViewController *)controller;

@end
