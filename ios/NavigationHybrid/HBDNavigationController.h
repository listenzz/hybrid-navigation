//
//  HBDNavigationController.h
//
//  Created by Listen on 2017/12/16.
//

#import <UIKit/UIKit.h>

@interface HBDNavigationController : UINavigationController

- (instancetype)initWithRootModule:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

@end
