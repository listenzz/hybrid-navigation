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

static bool backTitleHidden = NO;

+ (void)setHideBackTitle:(BOOL)hidden {
    backTitleHidden = hidden;
}

+ (BOOL)isBackTitleHidden {
    return backTitleHidden;
}

+ (void)setTopBarStyle:(NSString *)style {
    if ([style isEqualToString:@"light-content"]) {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    } else {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    }
}

+ (void)setBackIcon:(NSDictionary *)icon {
    UIImage *backIcon = [RCTConvert UIImage:icon];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backIcon];
    [[UINavigationBar appearance] setBackIndicatorImage:backIcon];
}

+ (void)setTopBarBackgroundColor:(NSString *)color {
    UIColor *c = [RCTConvert UIColor:color];
    [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:c] forBarMetrics:UIBarMetricsDefault];
}

+ (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 8.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (void)setTopBarTintColor:(NSString *)color {
    UIColor *c = [RCTConvert UIColor:color];
    [[UINavigationBar appearance] setTintColor:c];
}

+ (void)setTitleTextColor:(NSString *)color {
    
}

+ (void)setTitleTextSize:(NSUInteger)dp {
    
}

+ (void)setBarButtonItemTintColor:(NSString *)color {
    UIColor *c = [RCTConvert UIColor:color];
    [[UIBarButtonItem appearance] setTintColor:c];
}

+ (void)setBarButtonItemTextSize:(NSUInteger)dp {
    
}

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

- (void)setHidesBackButton:(BOOL)hidden forController:(HBDViewController *)controller {
    controller.navigationItem.hidesBackButton = hidden;
}

@end
