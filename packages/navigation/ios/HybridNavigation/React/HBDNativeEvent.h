#import <Foundation/Foundation.h>
#import <navigation/navigation.h>
#import <React/RCTInitializing.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBDNativeEvent : NativeEventSpecBase <NativeEventSpec, RCTInvalidating, RCTInitializing>

+ (instancetype)getInstance;

@end

NS_ASSUME_NONNULL_END
