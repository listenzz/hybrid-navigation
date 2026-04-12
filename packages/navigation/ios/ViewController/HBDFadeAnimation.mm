#import "HBDFadeAnimation.h"

@implementation HBDFadeAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    if (!toView) {
        [transitionContext completeTransition:NO];
        return;
    }

    toView.frame = containerView.bounds;
    toView.alpha = 0;
    [containerView addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.alpha = 1;
    } completion:^(BOOL finished) {
        toView.alpha = 1;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
