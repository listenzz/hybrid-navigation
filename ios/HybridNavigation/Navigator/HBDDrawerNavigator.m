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
    NSDictionary *model = layout[self.name];
    if (!model) {
        return nil;
    }
    
    NSArray *children = model[@"children"];
    if (children.count < 2) {
        return nil;
    }
    
    UIViewController *content = [[HBDReactBridgeManager get] viewControllerWithLayout:children[0]];
    UIViewController *menu = [[HBDReactBridgeManager get] viewControllerWithLayout:children[1]];
    
    if (!content || !menu) {
        return nil;
    }

    HBDDrawerController *drawer = [[HBDDrawerController alloc] initWithContentViewController:content menuViewController:menu];
    NSDictionary *options = model[@"options"];

    if (options) {
        NSNumber *maxDrawerWidth = options[@"maxDrawerWidth"];
        if (maxDrawerWidth) {
            [drawer setMaxDrawerWidth:[maxDrawerWidth floatValue]];
        }

        NSNumber *minDrawerMargin = options[@"minDrawerMargin"];
        if (minDrawerMargin) {
            [drawer setMinDrawerMargin:[minDrawerMargin floatValue]];
        }

        NSNumber *menuInteractive = options[@"menuInteractive"];
        if (menuInteractive) {
            drawer.menuInteractive = [menuInteractive boolValue];
        }
    }

    return drawer;
}

- (NSDictionary *)routeGraphWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDDrawerController class]]) {
        return nil;
    }
    
    HBDDrawerController *drawer = (HBDDrawerController *) vc;
    NSDictionary *content = [[HBDReactBridgeManager get] routeGraphWithViewController:drawer.contentController];
    NSDictionary *menu = [[HBDReactBridgeManager get] routeGraphWithViewController:drawer.menuController];
    return @{
        @"layout": @"drawer",
        @"sceneId": drawer.sceneId,
        @"children": @[content, menu],
        @"mode": [drawer hbd_mode],
    };
}

- (HBDViewController *)primaryViewControllerWithViewController:(UIViewController *)vc {
    if (![vc isKindOfClass:[HBDDrawerController class]]) {
        return nil;
    }
    
    HBDDrawerController *drawer = (HBDDrawerController *) vc;
    if (drawer.isMenuOpened) {
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:drawer.menuController];
    } else {
        return [[HBDReactBridgeManager get] primaryViewControllerWithViewController:drawer.contentController];
    }
}

- (void)handleNavigationWithViewController:(UIViewController *)vc action:(NSString *)action extras:(NSDictionary *)extras callback:(RCTResponseSenderBlock)callback {
    if (!vc.hbd_inViewHierarchy) {
        callback(@[NSNull.null, @NO]);
        return;
    }
    
    HBDDrawerController *drawer = [vc drawerController];
    if (!drawer) {
        callback(@[NSNull.null, @NO]);
        return;
    }

    if (!drawer.hbd_viewAppeared) {
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
        [drawer toggleMenu];
        return;
    }
    
    if ([action isEqualToString:@"openMenu"]) {
        [drawer openMenu];
        return;
    }
    
    if ([action isEqualToString:@"closeMenu"]) {
        [drawer closeMenu];
        return;
    }
}

-(void)handleNavigation:(NSDictionary *)params {
    [self handleNavigationWithViewController:params[@"viewController"] action:params[@"action"] extras:params[@"extras"] callback:params[@"callback"]];
}

- (void)invalidate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
