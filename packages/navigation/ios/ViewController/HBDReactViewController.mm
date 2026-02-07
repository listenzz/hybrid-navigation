#import "HBDReactViewController.h"

#import "HBDReactBridgeManager.h"
#import "HBDRootView.h"
#import "HBDTitleView.h"
#import "HBDUtils.h"
#import "HBDNativeEvent.h"
#import "GlobalStyle.h"

#import <React/RCTConvert.h>
#import <React/RCTSurfaceHostingProxyRootView.h>

@interface HBDReactViewController ()

@property(nonatomic, assign) BOOL firstRenderCompleted;
@property(nonatomic, assign) BOOL viewAppeared;
@property(nonatomic, strong, readwrite) HBDRootView *rootView;

@end

@implementation HBDReactViewController {
    NSArray *_reactViewConstraints;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
    RCTLogInfo(@"[Navigation] 销毁页面 %@", self.moduleName);
}

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options {
    if (self = [super initWithModuleName:moduleName props:props options:options]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReload)
                                                     name:RCTBridgeWillReloadNotification object:nil];
    }
    return self;
}

- (void)handleReload {
    self.firstRenderCompleted = NO;
}

- (void)loadView {
	RCTHost *rctHost = [HBDReactBridgeManager get].rctHost;
	RCTFabricSurface *surface = [rctHost createSurfaceWithModuleName:self.moduleName initialProperties:[self propsWithSceneId]];
	HBDRootView *rootView = [[HBDRootView alloc] initWithSurface:(id)surface];
    self.rootView = rootView;

    BOOL passThroughTouches = [self.options[@"passThroughTouches"] boolValue];
    rootView.passThroughTouches = passThroughTouches;
    rootView.backgroundColor = UIColor.clearColor;
	rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = [[UIView alloc] init];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rootView];
    RCTLogInfo(@"[Navigation] 加载页面 %@", self.moduleName);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateReactViewConstraints];

    NSDictionary *titleItem = self.options[@"titleItem"];
    if (titleItem && self.navigationController) {
        if (self.hbd_barHidden) {
            return;
        }
        NSString *moduleName = titleItem[@"moduleName"];
        if (moduleName) {
            NSString *fitting = titleItem[@"layoutFitting"];
            CGSize size;
            if ([fitting isEqualToString:@"expanded"]) {
                size = UILayoutFittingExpandedSize;
            } else {
                size = UILayoutFittingCompressedSize;
            }

			RCTHost *host = [HBDReactBridgeManager get].rctHost;
			RCTFabricSurface *surface = [host createSurfaceWithModuleName:moduleName initialProperties:[self propsWithSceneId]];
			RCTSurfaceHostingProxyRootView *titleRootView = [[RCTSurfaceHostingProxyRootView alloc] initWithSurface:(id)surface];
            HBDTitleView *titleView = [[HBDTitleView alloc] initWithRootView:titleRootView layoutFittingSize:size navigationBarBounds:self.navigationController.navigationBar.bounds];
            self.navigationItem.titleView = titleView;
        }
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
	if (self.shouldAdjustSafeAreaTopToStatusBar) {
		CGFloat statusBarHeight = [self hbd_statusBarHeight];
		CGFloat currentEffectiveTop = self.view.safeAreaInsets.top;
		if (fabs(currentEffectiveTop - statusBarHeight) > 0.5) {
			CGFloat systemTop = currentEffectiveTop - self.additionalSafeAreaInsets.top;
			UIEdgeInsets o = self.additionalSafeAreaInsets;
			self.additionalSafeAreaInsets = UIEdgeInsetsMake(statusBarHeight - systemTop, o.left, o.bottom, o.right);
		}
	}
    [self updateReactViewConstraints];
}

- (CGFloat)hbd_statusBarHeight {
	if (@available(iOS 13.0, *)) {
		UIWindowScene *scene = self.view.window.windowScene;
		if (scene) {
			return scene.statusBarManager.statusBarFrame.size.height;
		}
	}
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}

/// 局部隐藏 topBar 或局部透明 topBar（非全局隐藏）时，需将 SafeArea 顶部修正为状态栏高度
- (BOOL)shouldAdjustSafeAreaTopToStatusBar {
	if ([GlobalStyle globalStyle].topBarHidden) {
		return NO;
	}
	if (![self.parentViewController isKindOfClass:UINavigationController.class]) {
		return NO;
	}
	return self.hbd_barHidden || self.hbd_barAlpha < 1.0 || colorHasAlphaComponent(self.hbd_barTintColor);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
	[self updateReactViewConstraints];
}

- (void)updateReactViewConstraints {
    if (self.isViewLoaded && self.rootView) {
		CGFloat bottomInset = self.shouldFitWindowInsetsBottom ?  0: self.tabBarController.tabBar.frame.size.height;
		CGFloat topInset = self.shouldFitWindowInsetsTop ? 0 : self.view.safeAreaInsets.top;
		[self.rootView setFrame:CGRectMake(
			0,
			topInset,
			self.view.frame.size.width,
			self.view.frame.size.height - topInset - bottomInset
		)];
    }
}

- (BOOL)shouldFitWindowInsetsTop {
    if (![self.parentViewController isKindOfClass:UINavigationController.class]) {
        return YES;
    }
    BOOL isTranslucent = self.hbd_barHidden || self.hbd_barAlpha < 1.0 || colorHasAlphaComponent(self.hbd_barTintColor);
    return isTranslucent || self.extendedLayoutIncludesOpaqueBars;
}

- (BOOL)shouldFitWindowInsetsBottom {
	if (self.navigationController && self.tabBarController) {
		return self != [self.navigationController.viewControllers firstObject];
	}
	return YES;
}

- (NSDictionary *)propsWithSceneId {
    NSMutableDictionary *props;
    if (self.props) {
        props = [self.props mutableCopy];
    } else {
        props = [@{} mutableCopy];
    }
    props[@"sceneId"] = self.sceneId;
    return props;
}

- (void)setAppProperties:(NSDictionary *)props {
    [super setAppProperties:props];
    if ([HBDReactBridgeManager get].isReactModuleRegisterCompleted) {
        self.rootView.appProperties = [self propsWithSceneId];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator && !coordinator.interactive) {
        if (!self.viewAppeared) {
            self.viewAppeared = YES;
            if (self.firstRenderCompleted) {
				[[HBDNativeEvent getInstance] emitOnComponentAppear:@{
					@"sceneId": self.sceneId,
				}];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewAppeared) {
        self.viewAppeared = YES;
        if (self.firstRenderCompleted) {
			[[HBDNativeEvent getInstance] emitOnComponentAppear:@{
				@"sceneId": self.sceneId,
			}];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator && !coordinator.interactive) {
        if (self.viewAppeared) {
            self.viewAppeared = NO;
            if (self.firstRenderCompleted) {
				[[HBDNativeEvent getInstance] emitOnComponentDisappear:@{
					@"sceneId": self.sceneId,
				}];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.viewAppeared) {
        self.viewAppeared = NO;
        if (self.firstRenderCompleted) {
			[[HBDNativeEvent getInstance] emitOnComponentDisappear:@{
				@"sceneId": self.sceneId,
			}];
        }
    }
}

- (void)signalFirstRenderComplete {
    if (self.firstRenderCompleted) {
        return;
    }
    self.firstRenderCompleted = YES;
    if (self.viewAppeared) {
		if (self.firstRenderCompleted) {
			[[HBDNativeEvent getInstance] emitOnComponentAppear:@{
				@"sceneId": self.sceneId,
			}];
		}
    }
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
	[[HBDNativeEvent getInstance] emitOnResult:@{
		@"requestCode": @(requestCode),
		@"resultCode": @(resultCode),
		@"resultData": RCTNullIfNil(data),
		@"sceneId": self.sceneId,
	}];
}


@end
