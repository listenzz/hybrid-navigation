//
//  UIViewController+HBD.h
//
//  Created by Listen on 2018/1/22.
//

#import <UIKit/UIKit.h>
#import "HBDDrawerController.h"

@interface UIViewController (HBD)

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data;

- (NSInteger)resultCode;

- (NSDictionary *)resultData;

- (void)setRequestCode:(NSInteger)requestCode;

- (NSInteger)requestCode;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

- (HBDDrawerController *)drawerController;

@end
