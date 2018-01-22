//
//  HBDViewController.h
//
//  Created by Listen on 2017/11/25.
//

#import <UIKit/UIKit.h>
#import "UIViewController+HBD.h"

@class HBDNavigator;

@interface HBDViewController : UIViewController

@property(nonatomic, copy, readonly) NSString *sceneId;
@property(nonatomic, copy, readonly) NSString *moduleName;
@property(nonatomic, copy, readonly) NSDictionary *props;
@property(nonatomic, copy) NSDictionary *options;

- (instancetype)initWithModuleName:(NSString *)moduleName props:(NSDictionary *)props options:(NSDictionary *)options;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

@end
