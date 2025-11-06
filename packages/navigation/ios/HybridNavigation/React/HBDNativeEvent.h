//
//  HBDNativeEvent.h
//  HybridNavigation
//
//  Created by 李生 on 2025/11/2.
//

#import <Foundation/Foundation.h>
#import <navigation/navigation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBDNativeEvent : NativeEventSpecBase <NativeEventSpec>

+ (instancetype)getInstance;

@end

NS_ASSUME_NONNULL_END
