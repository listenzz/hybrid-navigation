//
//  HBDReactViewController.h
//
//  Created by Listen on 2017/11/26.
//

#import "HBDViewController.h"

@interface HBDReactViewController : HBDViewController

- (instancetype)initWithNavigator:(HBDNavigator *)navigator moduleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

@end
