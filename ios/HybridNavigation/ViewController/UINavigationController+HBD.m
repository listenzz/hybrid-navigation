#import "UINavigationController+HBD.h"

@implementation UINavigationController (HBD)

- (void)redirectToViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self redirectToViewController:controller target:self.topViewController animated:animated];
}

- (void)redirectToViewController:(UIViewController *)controller target:(UIViewController *)target animated:(BOOL)animated {
    NSMutableArray *children = [self.childViewControllers mutableCopy];
    NSUInteger index = [children indexOfObject:target];
    if (index == NSNotFound) {
        return;
    }
    NSUInteger count = self.childViewControllers.count;
    [children removeObjectsInRange:NSMakeRange(index, count - index)];
    [children addObject:controller];
    if (children.count > 1) {
        controller.hidesBottomBarWhenPushed = self.hidesBottomBarWhenPushed;
    }
    [self setViewControllers:children animated:YES];
}

@end
