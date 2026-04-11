#import "HBDViewController.h"

#import "HBDUtils.h"
#import "GlobalStyle.h"
#import "UIImage+WithBadge.h"

#import <React/RCTLog.h>

@interface HBDViewController ()

@property(nonatomic, copy, readwrite) NSDictionary *props;
@property(nonatomic, copy, readwrite) NSDictionary *options;
@property(nonatomic, assign) BOOL forceTransparentDialogWindow;
@property(nonatomic, assign) BOOL forceScreenLandscape;
@property(nonatomic, assign, readwrite) BOOL animatedTransition;

@end

@implementation HBDViewController

- (void)dealloc {
    // 
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithModuleName:nil props:nil options:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithModuleName:nil props:nil options:nil];
}

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _moduleName = moduleName;
        _options = options;
        _props = props;
        _animatedTransition = YES;
        
        if (options[@"animatedTransition"]) {
            _animatedTransition = [options[@"animatedTransition"] boolValue];
        }
        
        if (options[@"forceScreenLandscape"]) {
            _forceScreenLandscape = [options[@"forceScreenLandscape"] boolValue];
        }
        
        self.forceTransparentDialogWindow = [options[@"forceTransparentDialogWindow"] boolValue];
		if (self.forceTransparentDialogWindow) {
			_animatedTransition = NO;
		}
        
        [self applyNavigationBarOptions:options];
        [self applyTabBarOptions:options];
    }
    return self;
}

- (void)setAppProperties:(NSDictionary *)props {
    self.props = props;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.hbd_barStyle == UIBarStyleDefault ? UIStatusBarStyleDarkContent : UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return [self hbd_statusBarHidden];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.options[@"homeIndicatorAutoHiddenIOS"]) {
        return [self.options[@"homeIndicatorAutoHiddenIOS"] boolValue];
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!self.navigationController.transitionCoordinator.interactive) {
		[self adjustScreenOrientation];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self adjustScreenOrientation];
}

- (void)adjustScreenOrientation {
	UIWindowScene *windowScene = [self getWindowScene];

	if (!self.forceScreenLandscape && windowScene != nil && windowScene.interfaceOrientation != UIInterfaceOrientationPortrait && ![[self hbd_mode] isEqual:@"modal"]) {
		[self setScreenOrientation:UIInterfaceOrientationPortrait usingMask:UIInterfaceOrientationMaskPortrait];
	}

	if (self.forceScreenLandscape) {
		[self setScreenOrientation:UIInterfaceOrientationLandscapeRight usingMask:UIInterfaceOrientationMaskLandscape];
	}
}

- (void)setScreenOrientation:(UIInterfaceOrientation) orientation usingMask:(UIInterfaceOrientationMask) mask {
    [GlobalStyle globalStyle].interfaceOrientation = mask;
    if (@available(iOS 16.0, *)) {
            UIWindowScene *windowScene = [self getWindowScene];
            if (windowScene != nil) {
                UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask];
                [windowScene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
    #if DEBUG
                    if (error) {
                        NSLog(@"Failed to update geometry with UIInterfaceOrientationMask: %@", error);
                    }
    #endif
                }];
            }
    }  else {
        UIDevice* currentDevice = [UIDevice currentDevice];
        [currentDevice setValue:@(UIInterfaceOrientationUnknown) forKey:@"orientation"];
        [currentDevice setValue:@(orientation) forKey:@"orientation"];
    }
    
    [UIViewController attemptRotationToDeviceOrientation];
}

- (UIWindowScene *)getWindowScene {
    UIWindow *window = self.view.window ?: self.navigationController.view.window;
    if ([window.windowScene isKindOfClass:[UIWindowScene class]]) {
        return window.windowScene;
    }

    NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
    for (id connectedScene in array) {
        if ([connectedScene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *scene = (UIWindowScene *)connectedScene;
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                return scene;
            }
        }
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setScreenBackgroundColor];
}

- (void)setScreenBackgroundColor {
    if (self.modalPresentationStyle == UIModalPresentationOverFullScreen) {
        [self setModalBackgroundColor];
        return;
    }
    
    NSString *screenColor = self.options[@"screenBackgroundColor"];
    if (screenColor) {
        self.view.backgroundColor = [HBDUtils colorWithHexString:screenColor];
    } else {
        self.view.backgroundColor = [GlobalStyle globalStyle].screenBackgroundColor;
    }
}

- (void)setModalBackgroundColor {
    if (self.forceTransparentDialogWindow) {
        self.view.backgroundColor = UIColor.clearColor;
        return;
    }
    
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    
    NSString *screenColor = self.options[@"screenBackgroundColor"];
    
    if (!screenColor) {
        return;
    }

    UIColor *color = [HBDUtils colorWithHexString:screenColor];
    if (colorHasAlphaComponent(color)) {
        self.view.backgroundColor = color;
    }
}

- (void)applyTabBarOptions:(NSDictionary *)options {
    NSDictionary *tabItem = options[@"tabItem"];
    if (tabItem) {
		UITabBarItem *tabBarItem = self.navigationController ? self.navigationController.tabBarItem : self.tabBarItem;
		// title
        tabBarItem.title = tabItem[@"title"];

		// badge
		NSDictionary *badge = tabItem[@"badge"];
		tabBarItem.badgeValue = [self badgeText:badge];
		tabBarItem.badgeColor = [UITabBarItem appearance].badgeColor;
		
		NSDictionary *unselectedIcon = tabItem[@"unselectedIcon"];
		NSDictionary *icon = tabItem[@"icon"];
		UITabBar *appearance = self.tabBarController.tabBar ?: [UITabBar appearance];
		BOOL dot = [self showDotBadge:badge];
		
		UITabBarItemAppearance *itemAppearance = appearance.standardAppearance.stackedLayoutAppearance;
		if (unselectedIcon) {
			tabBarItem.image = [[HBDUtils UIImage:unselectedIcon] withIconColor:itemAppearance.normal.iconColor badgeColor:dot ? tabBarItem.badgeColor : UIColor.clearColor];
			tabBarItem.selectedImage = [[HBDUtils UIImage:icon] withIconColor:itemAppearance.selected.iconColor badgeColor:dot ? tabBarItem.badgeColor : UIColor.clearColor];
		} else {
			tabBarItem.image = [[HBDUtils UIImage:icon] withIconColor:itemAppearance.normal.iconColor badgeColor:dot ? tabBarItem.badgeColor : UIColor.clearColor];
			tabBarItem.selectedImage = [[HBDUtils UIImage:icon] withIconColor:itemAppearance.selected.iconColor badgeColor:dot ? tabBarItem.badgeColor : UIColor.clearColor];
		}
		if (!self.navigationController) {
        	self.tabBarItem = tabBarItem;
		}
    }
}

- (void)updateTabBarItem:(NSDictionary *)option {
	// title
	NSString *title = option[@"title"];
	if (title != nil) {
		self.options[@"tabItem"][@"title"] = title;
	}

	// badge
	NSDictionary *badge = option[@"badge"];
	if (badge != nil) {
		self.options[@"tabItem"][@"badge"] = badge;
	}
	
	// icon
	NSDictionary *icon = option[@"icon"];
	if (icon != nil) {
		self.options[@"tabItem"][@"icon"] = icon[@"selected"];
		self.options[@"tabItem"][@"unselectedIcon"] = icon[@"unselected"];
	}
	
	[self applyTabBarOptions:self.options];
}

- (BOOL)showDotBadge:(NSDictionary *)badge {
	if (badge) {
		BOOL hidden = badge[@"hidden"] ? [badge[@"hidden"] boolValue] : YES;
		return hidden ? NO : (badge[@"dot"] ? [badge[@"dot"] boolValue] : NO);
	}
	return NO;
}

- (NSString *)badgeText:(NSDictionary *)badge {
	if (badge) {
		BOOL hidden = badge[@"hidden"] ? [badge[@"hidden"] boolValue] : YES;
		return hidden ? nil : (badge[@"text"] ? badge[@"text"] : nil);
	}
	return nil;
}

- (void)applyNavigationBarOptions:(NSDictionary *)options {
    NSString *statusBarStyle = options[@"statusBarStyle"];
    if (statusBarStyle) {
        if ([statusBarStyle isEqualToString:@"dark-content"]) {
            self.hbd_barStyle = UIBarStyleDefault;
        } else {
            self.hbd_barStyle = UIBarStyleBlack;
        }
    }

    // Native TopBar has been removed and UINavigationBar stays hidden.
    self.extendedLayoutIncludesOpaqueBars = YES;

    NSNumber *swipeBackEnabled = options[@"swipeBackEnabled"];
    if (swipeBackEnabled) {
        self.hbd_swipeBackEnabled = [swipeBackEnabled boolValue];
    }

    NSNumber *statusBarHidden = options[@"statusBarHidden"];
    if (statusBarHidden) {
        self.hbd_statusBarHidden = [statusBarHidden boolValue];
    }

    NSNumber *backInteractive = options[@"backInteractive"];
    if (backInteractive) {
        self.hbd_backInteractive = [backInteractive boolValue];
    }
}

- (void)updateNavigationBarOptions:(NSDictionary *)options {
    self.options = [HBDUtils mergeItem:options withTarget:self.options];

    NSMutableDictionary *target = [options mutableCopy];

    [self applyNavigationBarOptions:target];

    NSString *screenColor = options[@"screenBackgroundColor"];
    if (screenColor && [self isViewLoaded]) {
        self.view.backgroundColor = [HBDUtils colorWithHexString:screenColor];
    }

    if (options[@"statusBarHidden"] || options[@"statusBarStyle"]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }

    if (options[@"homeIndicatorAutoHiddenIOS"]) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }

}

@end
