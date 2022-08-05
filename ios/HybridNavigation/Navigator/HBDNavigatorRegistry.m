#import "HBDNavigatorRegistry.h"

#import "HBDScreenNavigator.h"
#import "HBDStackNavigator.h"
#import "HBDTabNavigator.h"
#import "HBDDrawerNavigator.h"
#import "HBDNavigationController.h"
#import "HBDTabBarController.h"

#import <React/RCTLog.h>

@interface HBDNavigatorRegistry ()

@property(nonatomic, strong) NSMutableArray<NSString *> *layouts;
@property(nonatomic, strong) NSMutableArray<id <HBDNavigator>> *navigators;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id <HBDNavigator>> *actionNavigatorPairs;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id <HBDNavigator>> *layoutNavigatorPairs;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *classLayoutPairs;

@end

@implementation HBDNavigatorRegistry

- (instancetype)init {
    if (self = [super init]) {
        _layouts = [NSMutableArray new];
        _actionNavigatorPairs = [NSMutableDictionary new];
        _layoutNavigatorPairs = [NSMutableDictionary new];
        _classLayoutPairs = [NSMutableDictionary new];
    }

    [self registerNavigator:[HBDStackNavigator new]];
    [self registerNavigator:[HBDScreenNavigator new]];
    [self registerNavigator:[HBDTabNavigator new]];
    [self registerNavigator:[HBDDrawerNavigator new]];

    return self;
}

- (void)registerNavigator:(id <HBDNavigator>)navigator {
    

    for (NSString *action in [navigator supportActions]) {
        id <HBDNavigator> duplicated = self.actionNavigatorPairs[action];
        if (duplicated) {
            RCTLogError(@"[Navigator] The action %@ that %@ wants to register has been registered by %@", action, [navigator class], [duplicated class]);
        }
        self.actionNavigatorPairs[action] = navigator;
    }

    NSString *layout = [navigator name];
    [self.layouts addObject:layout];
    
    id <HBDNavigator> duplicatedLayout = self.layoutNavigatorPairs[layout];
    if (duplicatedLayout) {
        RCTLogError(@"[Navigator] The layout %@ that %@ wants to register has been registered by %@", layout, [navigator class], [duplicatedLayout class]);
    }
    self.layoutNavigatorPairs[layout] = navigator;
    
    [self.navigators addObject:navigator];
}

- (id <HBDNavigator>)navigatorForAction:(NSString *)action {
    return self.actionNavigatorPairs[action];
}

- (id <HBDNavigator>)navigatorForLayout:(NSString *)layout {
    return self.layoutNavigatorPairs[layout];
}

- (NSString *)layoutForViewController:(UIViewController *)vc {
    NSString *layout = self.classLayoutPairs[NSStringFromClass([vc class])];
    if (layout) {
        return layout;
    }
   
    if ([vc isKindOfClass:[HBDViewController class]]) {
        return @"screen";
    }
    if ([vc isKindOfClass:[HBDNavigationController class]]) {
        return @"stack";
    }
    if ([vc isKindOfClass:[HBDTabBarController class]]) {
        return @"tabs";
    }
    if ([vc isKindOfClass:[HBDDrawerController class]]) {
        return @"drawer";
    }
    
    return nil;
}

- (void)setLayout:(NSString *)layout forViewController:(UIViewController *)vc {
    NSString *current = self.classLayoutPairs[NSStringFromClass([vc class])];
    if (!current || ![current isEqualToString:layout]) {
        self.classLayoutPairs[NSStringFromClass([vc class])] = layout;
    }
}

- (NSArray<NSString *> *)allLayouts {
    return [self.layouts copy];
}

- (NSArray<id<HBDNavigator>> *)allNavigators {
    return [self.navigators copy];
}

@end
