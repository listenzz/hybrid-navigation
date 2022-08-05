#import "HBDDrawerNavigator.h"

#import "HBDReactBridgeManager.h"

@implementation HBDDrawerNavigator

- (NSString *)name {
    return @"drawer";
}

- (NSArray<NSString *> *)supportActions {
    return @[@"toggleMenu", @"openMenu", @"closeMenu"];
}

- (UIViewController *)viewControllerWithLayout:(NSDictionary *)layout {
    NSDictionary *drawer = layout[self.name];
    if (!drawer) {
        return nil;
    }
    
    NSArray *children = drawer[@"children"];
    if (children.count < 2) {
        return nil;
    }
    
    UIViewController *contentVC = [[HBDReactBridgeManager get] viewControllerWithLayout:children[0]];
    UIViewController *menuVC = [[HBDReactBridgeManager get] viewControllerWithLayout:children[1]];
    
    if (!contentVC || !menuVC) {
        return nil;
    }

    HBDDrawerController *drawerVC = [[HBDDrawerController alloc] initWithContentViewController:contentVC menuViewController:menuVC];
    NSDictionary *options = drawer[@"options"];

    if (options) {
        NSNumber *maxDrawerWidth = options[@"maxDrawerWidth"];
        if (maxDrawerWidth) {
            [drawerVC setMaxDrawerWidth:[maxDrawerWidth floatValue]];
        }

        NSNumber *minDrawerMargin = options[@"minDrawerMargin"];
        if (minDrawerMargin) {
            [drawerVC setMinDrawerMargin:[minDrawerMargin floatValue]];
        }

        NSNumber *menuInteractive = options[@"menuInteractive"];
        if (menuInteractive) {
            drawerVC.menuInteractive = [menuInteractive boolValue];
        }
    }

    return drawerVC;
}

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDDrawerController class]]) {
        return nil;
    }
    
    HBDDrawerController *drawerVC = (HBDDrawerController *) vc;
    NSDictionary *content = [[HBDReactBridgeManager get] routeGraphWithViewController:drawerVC.contentController];
    NSDictionary *menu = [[HBDReactBridgeManager get] routeGraphWithViewController:drawerVC.menuController];
    return @{
        @"layout": @"drawer",
        @"sceneId": drawerVC.sceneId,
        @"children": @[content, menu],
        @"mode": [drawerVC hbd_mode],
    };
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDDrawerController class]]) {
        return nil;
    }
    
    HBDDrawerController *drawerVC = (HBDDrawerController *) vc;
    if (drawerVC.isMenuOpened) {
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:drawerVC.menuController];
    } else {
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:drawerVC.contentController];
    }
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    if (!vc.hbd_inViewHierarchy) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    HBDDrawerController *drawerVC = [vc drawerController];
    if (!drawerVC) {
        callback(@[NSNull.null, @NO]);
        return;
    }

    if (!drawerVC.hbd_viewAppeared) {
        [self performSelector:@selector(handleNavigation:) withObject:@{
            @"viewController": vc,
            @"action": action,
            @"extras": extras,
            @"callback": callback,
        } afterDelay:0.05];
        return;
    }
    
    callback(@[NSNull.null, @YES]);

    if ([action isEqualToString:@"toggleMenu"]) {
        [drawerVC toggleMenu];
        return;
    }
    
    if ([action isEqualToString:@"openMenu"]) {
        [drawerVC openMenu];
        return;
    }
    
    if ([action isEqualToString:@"closeMenu"]) {
        [drawerVC closeMenu];
    }
}

-(void)handleNavigation:(NSDictionary *)params {
    [self handleNavigationWithViewController:params[@"viewController"] action:params[@"action"] extras:params[@"extras"] callback:params[@"callback"]];
}

- (void)invalidate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
