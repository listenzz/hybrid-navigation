//
//  HBDReactViewController.m
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDReactViewController.h"
#import "HBDReactBridgeManager.h"
#import "HBDTitleView.h"
#import "HBDRootView.h"
#import "HBDEventEmitter.h"

#import <React/RCTConvert.h>
#import <React/RCTLog.h>

@interface HBDReactViewController ()

@property(nonatomic, assign) BOOL firstRenderCompleted;
@property(nonatomic, assign) BOOL viewAppeared;
@property(nonatomic, strong, readwrite) RCTRootView *rootView;

@end

@implementation HBDReactViewController

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
    RCTRootView *rootView = [[HBDRootView alloc] initWithBridge:[HBDReactBridgeManager get].bridge moduleName:self.moduleName initialProperties:[self propsWithSceneId]];
    BOOL passThroughTouches = [self.options[@"passThroughTouches"] boolValue];
    rootView.passThroughTouches = passThroughTouches;
    self.view = rootView;
    self.rootView = rootView;
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
            RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[HBDReactBridgeManager get].bridge moduleName:moduleName initialProperties:[self propsWithSceneId]];
            HBDTitleView *titleView = [[HBDTitleView alloc] initWithRootView:rootView layoutFittingSize:size navigationBarBounds:self.navigationController.navigationBar.bounds];
            self.navigationItem.titleView = titleView;
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
    [props setObject:self.sceneId forKey:@"sceneId"];
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
    self.automaticallyAdjustsScrollViewInsets = NO;
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
        } else {
            [HBDEventEmitter sendEvent:EVENT_NAVIGATION data:@{
                                                               KEY_SCENE_ID: self.sceneId,
                                                               KEY_ON: ON_COMPONENT_MOUNT
                                                               }];
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
                                                       KEY_RESULT_DATA: data ?: [NSNull null],
                                                       KEY_SCENE_ID: self.sceneId,
                                                       }];
}


@end
