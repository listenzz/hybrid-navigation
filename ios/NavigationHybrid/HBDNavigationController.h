//
//  HBDNavigationController.h
//
//  Created by Listen on 2017/12/16.
//

#import <UIKit/UIKit.h>
#import "HBDNavigator.h"

@interface HBDNavigationController : UINavigationController

@property(nonatomic, strong, readonly) HBDNavigator *navigator;

- (instancetype)initWithRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

@end
