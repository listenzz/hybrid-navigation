//
//  HBDViewController.h
//  Pods
//
//  Created by Listen on 2017/11/25.
//

#import <UIKit/UIKit.h>
#import "HBDNavigator.h"

@class HBDNavigator;

@interface HBDViewController : UIViewController

@property(nonatomic, copy, readonly) NSString *sceneId;
@property(nonatomic, weak, readonly) HBDNavigator *navigator;

- (instancetype)initWithNavigator:(HBDNavigator *)navigator;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

@end
