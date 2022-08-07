#import "HBDReactViewController.h"

#import "HBDReactBridgeManager.h"
#import "HBDTitleView.h"
#import "HBDRootView.h"
#import "HBDEventEmitter.h"
#import "HBDUtils.h"

#import <React/RCTConvert.h>

@interface HBDReactViewController ()

@property(nonatomic, assign) BOOL firstRenderCompleted;
@property(nonatomic, assign) BOOL viewAppeared;
@property(nonatomic, strong, readwrite) RCTRootView *rootView;

@end

@implementation HBDReactViewController {
    NSArray *_reactViewConstraints;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
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
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[HBDReactBridgeManager get].bridge moduleName:self.moduleName initialProperties:[self propsWithSceneId]];
    self.rootView = rootView;

    BOOL passThroughTouches = [self.options[@"passThroughTouches"] boolValue];
    rootView.passThroughTouches = passThroughTouches;
    rootView.backgroundColor = UIColor.clearColor;
    rootView.translatesAutoresizingMaskIntoConstraints = NO;
    self.view = [[HBDRootView alloc] initWithRootView:rootView];
    [self.view addSubview:rootView];
    [self updateReactViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            RCTRootView *titleRootView = [[RCTRootView alloc] initWithBridge:[HBDReactBridgeManager get].bridge moduleName:moduleName initialProperties:[self propsWithSceneId]];
            HBDTitleView *titleView = [[HBDTitleView alloc] initWithRootView:titleRootView layoutFittingSize:size navigationBarBounds:self.navigationController.navigationBar.bounds];
            self.navigationItem.titleView = titleView;
        }
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self updateReactViewConstraints];
}

- (void)updateReactViewConstraints {
    if (self.isViewLoaded && self.rootView) {
        [NSLayoutConstraint deactivateConstraints:_reactViewConstraints];
        _reactViewConstraints = @[
            [self.rootView.topAnchor
             constraintEqualToAnchor:self.shouldFitWindowInsetTop ? self.view.topAnchor : self.view.safeAreaLayoutGuide.topAnchor],
            [self.rootView.bottomAnchor
                constraintEqualToAnchor:self.view.bottomAnchor],
            [self.rootView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
            [self.rootView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
        ];
        [NSLayoutConstraint activateConstraints:_reactViewConstraints];
    }
}

- (BOOL)shouldFitWindowInsetTop {
    if (![self.parentViewController isKindOfClass:UINavigationController.class]) {
        return YES;
    }
    BOOL isTranslucent = self.hbd_barHidden || self.hbd_barAlpha < 1.0 || colorHasAlphaComponent(self.hbd_barTintColor);
    return isTranslucent || self.extendedLayoutIncludesOpaqueBars;
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
                [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                    KEY_SCENE_ID: self.sceneId,
                    KEY_ON: ON_COMPONENT_APPEAR
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
            [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                KEY_SCENE_ID: self.sceneId,
                KEY_ON: ON_COMPONENT_APPEAR
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
                [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                    KEY_SCENE_ID: self.sceneId,
                    KEY_ON: ON_COMPONENT_DISAPPEAR
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
            [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                KEY_SCENE_ID: self.sceneId,
                KEY_ON: ON_COMPONENT_DISAPPEAR
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
        [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
            KEY_SCENE_ID: self.sceneId,
            KEY_ON: ON_COMPONENT_APPEAR
        }];
    }
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
        KEY_ON: ON_COMPONENT_RESULT,
        KEY_REQUEST_CODE: @(requestCode),
        KEY_RESULT_CODE: @(resultCode),
        KEY_RESULT_DATA: RCTNullIfNil(data),
        KEY_SCENE_ID: self.sceneId,
    }];
}


@end
