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

#import <React/RCTRootView.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTConvert.h>

@interface HBDReactViewController ()

@property(nonatomic, assign) BOOL firstRenderComplete;
@property(nonatomic, assign) BOOL viewAppeared;

@end

@implementation HBDReactViewController

- (void)loadView {
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[HBDReactBridgeManager sharedInstance].bridge moduleName:self.moduleName initialProperties:[self propsWithSceneId]];
    self.view = rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *titleItem = self.options[@"titleItem"];
    if (titleItem && self.navigationController) {
        if (self.topBarHidden) {
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
            RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[HBDReactBridgeManager sharedInstance].bridge moduleName:moduleName initialProperties:[self propsWithSceneId]];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewAppeared) {
        self.viewAppeared = YES;
        if (self.firstRenderComplete) {
            RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"NavigationHybrid"];
            [emitter sendEventWithName:@"ON_COMPONENT_APPEAR" body:@{
                                                                     @"sceneId": self.sceneId,
                                                                     }];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.viewAppeared) {
        self.viewAppeared = NO;
        RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"NavigationHybrid"];
        [emitter sendEventWithName:@"ON_COMPONENT_DISAPPEAR" body:@{
                                                                    @"sceneId": self.sceneId,
                                                                    }];
    }
}

- (void)signalFirstRenderComplete {
    self.firstRenderComplete = YES;
    if (self.viewAppeared) {
        RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"NavigationHybrid"];
        [emitter sendEventWithName:@"ON_COMPONENT_APPEAR" body:@{
                                                                 @"sceneId": self.sceneId,
                                                                 }];
    }
}

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode {
    [super didReceiveResultCode:resultCode resultData:data requestCode:requestCode];
    RCTEventEmitter *emitter = [[HBDReactBridgeManager sharedInstance].bridge moduleForName:@"NavigationHybrid"];
    [emitter sendEventWithName:@"ON_COMPONENT_RESULT" body:@{@"requestCode": @(requestCode),
                                                                @"resultCode": @(resultCode),
                                                                @"data": data ?: [NSNull null],
                                                                @"sceneId": self.sceneId,
                                                                }];
}


@end
