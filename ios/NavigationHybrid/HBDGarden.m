//
//  HBDGarden.m
//  Pods
//
//  Created by Listen on 2017/11/26.
//

#import "HBDGarden.h"
#import <React/RCTConvert.h>
#import <React/RCTEventEmitter.h>

#import "HBDBarButtonItem.h"
#import "HBDReactBridgeManager.h"


@implementation HBDGarden

- (void)setLeftBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        controller.navigationItem.leftBarButtonItem = [self createBarButtonItem:item forController:controller];
    } else {
        controller.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setRightBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        controller.navigationItem.rightBarButtonItem = [self createBarButtonItem:item forController:controller];
    } else {
        controller.navigationItem.rightBarButtonItem = nil;
    }
}

- (HBDBarButtonItem *)createBarButtonItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    HBDBarButtonItem *barButtonItem;
    NSDictionary *icon = item[@"icon"];
    if (icon) {
        UIImage *iconImage = [RCTConvert UIImage:icon];
        barButtonItem = [[HBDBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain];
    } else {
        NSString *title = item[@"title"];
        barButtonItem = [[HBDBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain];
    }
    
    NSString *action = item[@"action"];
    NSString *navId = controller.navigator.navId;
    NSString *sceneId = controller.sceneId;
    barButtonItem.actionBlock = ^{
        RCTEventEmitter *emitter = [[HBDReactBridgeManager instance].bridge moduleForName:@"NavigationHybrid"];
        [emitter sendEventWithName:ON_BAR_BUTTON_ITEM_CLICK_EVENT body:@{
                                                                         @"action": action,
                                                                         @"navId": navId,
                                                                         @"sceneId": sceneId
                                                                         }];
    };
    return barButtonItem;
}

- (void)setTitleItem:(NSDictionary *)item forController:(HBDViewController *)controller {
    if (item) {
        NSString *title = item[@"title"];
        controller.navigationItem.title = title;
    } else {
        controller.navigationItem.title = nil;
    }
}

@end
