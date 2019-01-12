//
//  HBDReactViewController.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDViewController.h"

@class RCTRootView;

@interface HBDReactViewController : HBDViewController

@property(nonatomic, strong, readonly) RCTRootView *rootView;

- (void)signalFirstRenderComplete;

@end
