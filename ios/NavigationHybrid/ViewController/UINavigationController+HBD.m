//
//  UINavigationController+HBD.m
//  NavigationHybrid
//
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "UINavigationController+HBD.h"

@implementation UINavigationController (HBD)

- (void)replaceViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self replaceViewController:controller target:self.topViewController animated:animated];
}

- (void)replaceViewController:(UIViewController *)controller target:(UIViewController *)target animated:(BOOL)animated {
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    NSMutableArray *children = [self.childViewControllers mutableCopy];
    NSInteger count = self.childViewControllers.count;
    for (NSInteger i = count - 1; i > -1; i--) {
        UIViewController *child = [children objectAtIndex:i];
        [children removeObjectAtIndex:i];
        if (child == target) {
            break;
        }
    }
    [children addObject:controller];
    if (children.count > 1) {
        controller.hidesBottomBarWhenPushed = self.hidesBottomBarWhenPushed;
    }
    [self setViewControllers:children animated:NO];
}

- (void)replaceToRootViewController:(UIViewController *)controller animated:(BOOL)animated {
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    [self setViewControllers:@[ controller ] animated:NO];
}

@end
