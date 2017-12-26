//
//  HBDUtils.h
//  Pods
//
//  Created by Listen on 2017/12/25.
//

#import <Foundation/Foundation.h>

@interface HBDUtils : NSObject

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target;

+ (UIColor *)colorWithHexString: (NSString *) hexString;

+ (UIImage *)UIImage:(NSDictionary *)json;

+ (UIImage*)imageWithColor:(UIColor*)color;

@end
