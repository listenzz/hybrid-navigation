#import "HBDReactViewController.h"

#import "HBDReactBridgeManager.h"
#import "HBDRootView.h"
#import "HBDUtils.h"
#import "HBDNativeEvent.h"
#import "GlobalStyle.h"

#import <React/RCTConvert.h>

@interface HBDReactViewController ()

@property(nonatomic, assign) BOOL firstRenderCompleted;
@property(nonatomic, assign) BOOL viewAppeared;
@property(nonatomic, strong, readwrite) HBDRootView *rootView;

@end

@implementation HBDReactViewController {
    NSArray *_reactViewConstraints;
}

- (void)syncRootViewBackgroundColor {
    if (!self.rootView) {
        return;
    }

    UIColor *backgroundColor = self.view.backgroundColor ?: UIColor.clearColor;
    self.rootView.backgroundColor = backgroundColor;
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
	rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = [[UIView alloc] init];
	self.view.backgroundColor = [GlobalStyle globalStyle].screenBackgroundColor;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self syncRootViewBackgroundColor];
    [self.view addSubview:rootView];
    RCTLogInfo(@"[Navigation] 加载页面 %@", self.moduleName);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self syncRootViewBackgroundColor];
    [self updateReactViewFrame];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateReactViewFrame];
}

- (void)updateReactViewFrame {
    if (self.isViewLoaded && self.rootView) {
        CGRect targetFrame = self.view.bounds;
        if (!CGRectEqualToRect(self.rootView.frame, targetFrame)) {
            [self.rootView setFrame:targetFrame];
        }
    }
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
