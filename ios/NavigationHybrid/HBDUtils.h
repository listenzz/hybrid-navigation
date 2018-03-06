//
//  HBDUtils.h
//  NavigationHybrid
//
//  Created by Listen on 2017/12/25.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBDUtils : NSObject

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target;

+ (UIColor *)colorWithHexString: (NSString *) hexString;

+ (UIImage *)UIImage:(NSDictionary *)json;

+ (UIImage*)imageWithColor:(UIColor*)color;

+ (UIImageView *)findShadowImageAt:(UINavigationBar *)bar;

@end
