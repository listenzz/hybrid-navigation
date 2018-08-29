//
//  HBDViewController.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+HBD.h"
#import "UIViewController+StatusBar.h"

@class HBDNavigator;

@interface HBDViewController : UIViewController

@property(nonatomic, copy, readonly) NSString *sceneId;
@property(nonatomic, copy, readonly) NSString *moduleName;
@property(nonatomic, copy, readonly) NSDictionary *props;
@property(nonatomic, copy) NSDictionary *options;

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options NS_DESIGNATED_INITIALIZER;

- (void)setAppProperties:(NSDictionary *)props;

@end
