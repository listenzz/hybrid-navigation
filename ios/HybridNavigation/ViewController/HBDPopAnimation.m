//
//  HBDPopAnimation.m
//  HybridNavigation
//
//  Created by 李生 on 2019/9/26.
//

#import "HBDPopAnimation.h"

@implementation HBDPopAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    [[transitionContext containerView] insertSubview:toView belowSubview:fromView];

    toView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -transitionContext.containerView.bounds.size.width, 0);

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, transitionContext.containerView.bounds.size.width, 0);
    }                completion:^(BOOL finished) {
        toView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
