#import "HBDViewController+Garden.h"

#import "HBDBarButtonItem.h"
#import "HBDUtils.h"
#import "HBDNativeEvent.h"

#import <React/RCTConvert.h>

@implementation HBDViewController (Garden)

- (void)setLeftBarButtonItem:(NSDictionary *)item {
    if (self.hbd_barHidden) {
        return;
    }
    
    if (item) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        spacer.width = -8;
        [array addObject:spacer];
        
        UIBarButtonItem *buttonItem = [self createBarButtonItem:item];
        UIView *customView = buttonItem.customView;
        if ([customView isKindOfClass:[HBDImageBarButton class]]) {
            HBDImageBarButton *button = (HBDImageBarButton *)customView;
            button.imageEdgeInsets = buttonItem.imageInsets;
            button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, 4, 0, -4);
        }
        [array addObject:buttonItem];

        self.navigationItem.leftBarButtonItems = array;
    } else {
        self.navigationItem.leftBarButtonItems = nil;
    }
}

- (void)setRightBarButtonItem:(NSDictionary *)item {
    if (self.hbd_barHidden) {
        return;
    }
    
    if (item) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        spacer.width = -8;
        [array addObject:spacer];
        
        UIBarButtonItem *buttonItem = [self createBarButtonItem:item];
        UIView *customView = buttonItem.customView;
        if ([customView isKindOfClass:[HBDImageBarButton class]]) {
            HBDImageBarButton *button = (HBDImageBarButton *)customView;
            button.imageEdgeInsets = buttonItem.imageInsets;
            button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, -4, 0, 4);
        }
        [array addObject:buttonItem];

        self.navigationItem.rightBarButtonItems = array;
    } else {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (void)setLeftBarButtonItems:(NSArray *)items {
    if (self.hbd_barHidden) {
        return;
    }
    
    if (items) {
        NSArray *barButtonItems = [self createBarButtonItems:items];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        spacer.width = -8;
        [array addObject:spacer];
        
        [array addObjectsFromArray:barButtonItems];
        for (NSUInteger i = 0; i < barButtonItems.count; i++) {
            UIBarButtonItem *buttonItem = barButtonItems[i];
            UIView *customView = buttonItem.customView;
            if ([customView isKindOfClass:[HBDImageBarButton class]]) {
                HBDImageBarButton *button = (HBDImageBarButton *)customView;
                button.imageEdgeInsets = buttonItem.imageInsets;
                button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, 4, 0, -4);
            }
        }

        self.navigationItem.leftBarButtonItems = array;
    }
}

- (void)setRightBarButtonItems:(NSArray *)items {
    if (self.hbd_barHidden) {
        return;
    }
    
    if (items) {
        NSArray *barButtonItems = [self createBarButtonItems:items];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        spacer.width = -8;
        [array addObject:spacer];
        
        [array addObjectsFromArray:barButtonItems];
        for (NSUInteger i = 0; i < barButtonItems.count; i++) {
            UIBarButtonItem *buttonItem = barButtonItems[i];
            UIView *customView = buttonItem.customView;
            if ([customView isKindOfClass:[HBDImageBarButton class]]) {
                HBDImageBarButton *button = (HBDImageBarButton *)customView;
                button.imageEdgeInsets = buttonItem.imageInsets;
                button.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, -4, 0, 4);
            }
        }

        self.navigationItem.rightBarButtonItems = array;
    }
}

- (NSArray *)createBarButtonItems:(NSArray *)items {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < items.count; i++) {
        NSDictionary *item = items[i];
        [array addObject:[self createBarButtonItem:item]];
    }
    return array;
}

- (HBDBarButtonItem *)createBarButtonItem:(NSDictionary *)item {
    HBDBarButtonItem *barButtonItem;
    NSDictionary *icon = item[@"icon"];
    if (RCTNilIfNull(icon)) {
        UIImage *iconImage = [HBDUtils UIImage:icon];
        if (item[@"renderOriginal"] && [item[@"renderOriginal"] boolValue]) {
            iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        barButtonItem = [[HBDBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain];
    } else {
        NSString *title = item[@"title"];
        barButtonItem = [[HBDBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain];
    }

    NSNumber *enabled = item[@"enabled"];
    if (enabled) {
        barButtonItem.enabled = [enabled boolValue];
    }


    NSString *tintColor = item[@"tintColor"];
    if (tintColor) {
        barButtonItem.tintColor = [HBDUtils colorWithHexString:tintColor];
        UIView *customView = barButtonItem.customView;
        if ([customView isKindOfClass:[HBDImageBarButton class]] || [customView isKindOfClass:[HBDTextBarButton class]]) {
            UIButton *button = (UIButton *)customView;
            button.tintColor = [HBDUtils colorWithHexString:tintColor];
        }
    }
	
	NSString *action = item[@"action"];
	NSString *sceneId = self.sceneId;
    if (action) {
        barButtonItem.actionBlock = ^{
			[[HBDNativeEvent getInstance] emitOnBarButtonItemClick:@{
				@"action": action,
				@"sceneId": sceneId,
			}];
        };
    }
    return barButtonItem;
}

@end
