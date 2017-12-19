//
//  HBDGarden.h
//  Pods
//
//  Created by Listen on 2017/11/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HBDViewController.h"

@interface HBDGarden : NSObject

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller;

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller;

@end
