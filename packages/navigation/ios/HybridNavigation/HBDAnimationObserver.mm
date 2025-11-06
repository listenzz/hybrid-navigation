#import "HBDAnimationObserver.h"

@implementation HBDAnimationObserver {
    NSMutableArray<HBDAnimationEndedBlock> *_animationEndedBlocks;
}

- (instancetype)init {
    self = [super init];
    _animationEndedBlocks = [NSMutableArray array];
    return self;
}

+ (HBDAnimationObserver *)sharedObserver {
    static HBDAnimationObserver *_sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _sharedObserver = [[HBDAnimationObserver alloc] init];
    });

    return _sharedObserver;
}

- (void)registerAnimationEndedBlock:(HBDAnimationEndedBlock)block {
    [_animationEndedBlocks addObject:block];
}

- (void)beginAnimation {
    _isAnimating = YES;
}

- (void)endAnimation {
    _isAnimating = NO;

    for (HBDAnimationEndedBlock block in _animationEndedBlocks) {
        block();
    }

    [_animationEndedBlocks removeAllObjects];
}

- (void)invalidate {
    [_animationEndedBlocks removeAllObjects];
}

@end
