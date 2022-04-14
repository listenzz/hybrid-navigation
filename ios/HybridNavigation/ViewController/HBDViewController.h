//
//  HBDViewController.h
//  HybridNavigation
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+HBD.h"

@interface HBDViewController : UIViewController

@property(nonatomic, copy, readonly) NSString *moduleName;
@property(nonatomic, copy, readonly) NSDictionary *props;
@property(nonatomic, copy, readonly) NSDictionary *options;

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options NS_DESIGNATED_INITIALIZER;

- (void)setAppProperties:(NSDictionary *)props;

- (void)updateNavigationBarOptions:(NSDictionary *)options;

@end
