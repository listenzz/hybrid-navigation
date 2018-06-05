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
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    if (self.childViewControllers.count > 1) {
        [self popViewControllerAnimated:NO];
        controller.hidesBottomBarWhenPushed = self.hidesBottomBarWhenPushed;
        [self pushViewController:controller animated:NO];
    } else {
        [self setViewControllers:@[ controller ] animated:NO];
    }
}

- (void)replaceToRootViewController:(UIViewController *)controller animated:(BOOL)animated {
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.type = kCATransitionFade;
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    [self setViewControllers:@[controller] animated:NO];
}

@end
