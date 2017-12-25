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
@property(nonatomic, strong, readonly) HBDNavigator *navigator;

@property(nonatomic, copy, readonly) NSDictionary *props;
@property(nonatomic, copy) NSDictionary *options;

- (instancetype)initWithNavigator:(HBDNavigator *)navigator props:(NSDictionary *)props options:(NSDictionary *)options;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

@end
