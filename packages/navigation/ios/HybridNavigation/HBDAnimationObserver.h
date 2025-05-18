// fork from: https://github.com/wix/react-native-navigation/blob/master/lib/ios/AnimationObserver.h
#import <Foundation/Foundation.h>

typedef void (^HBDAnimationEndedBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface HBDAnimationObserver : NSObject

+ (HBDAnimationObserver *)sharedObserver;

@property(nonatomic) BOOL isAnimating;

- (void)registerAnimationEndedBlock:(HBDAnimationEndedBlock)block;

- (void)beginAnimation;

- (void)endAnimation;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
