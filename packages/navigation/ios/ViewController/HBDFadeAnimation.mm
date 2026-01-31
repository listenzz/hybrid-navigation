#import "HBDFadeAnimation.h"

@implementation HBDFadeAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    if (!toView) {
        [transitionContext completeTransition:NO];
        return;
    }
    
    if (fromView) {
        // Pop 操作：fromView 淡出，toView 淡入
        [containerView insertSubview:toView belowSubview:fromView];
        toView.alpha = 0;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.alpha = 0;
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            fromView.alpha = 1;
            toView.alpha = 1;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else {
        // Push 操作：toView 淡入（fromView 保持可见直到被移除）
        [containerView addSubview:toView];
        toView.alpha = 0;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            toView.alpha = 1;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

@end
