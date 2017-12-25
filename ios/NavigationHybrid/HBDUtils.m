//
//  HBDUtils.m
//  Pods
//
//  Created by Listen on 2017/12/25.
//

#import "HBDUtils.h"

@implementation HBDUtils

+ (NSDictionary *)mergeItem:(NSDictionary *)item withTarget:(NSDictionary *)target {
    NSMutableDictionary *mutableTarget = [target mutableCopy];
    for (NSString *key in [item allKeys]) {
        id obj = [item objectForKey:key];
        if (obj == nil) {
            //ignore
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *subTarget = [target objectForKey:key];
            if (!subTarget) {
                [mutableTarget setObject:obj forKey:key];
            } else {
                [mutableTarget setObject:[self mergeItem:obj withTarget:subTarget] forKey:key];
            }
        } else {
            [mutableTarget setObject:obj forKey:key];
        }
    }
    
    return [mutableTarget copy];
}

@end
