//
//  HBDGarden.h
//  Pods
//
//  Created by Listen on 2017/11/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HBDReactViewController.h"

@interface HBDGarden : NSObject

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDReactViewController *)controller;

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDReactViewController *)controller;

- (void)setTitleItem:(NSDictionary *)item forController:(HBDReactViewController *)controller;

@end
