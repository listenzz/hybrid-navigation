//
//  HBDNavigatorRegistry.m
//  NavigationHybrid
//
//  Created by 李生 on 2021/1/7.
//

#import "HBDNavigatorRegistry.h"

#import <React/RCTLog.h>

#import "HBDScreenNavigator.h"
#import "HBDStackNavigator.h"
#import "HBDTabNavigator.h"
#import "HBDDrawerNavigator.h"


@interface HBDNavigatorRegistry ()

@property(nonatomic, strong) NSMutableArray<id<HBDNavigator>> *navigators;
@property(nonatomic, strong) NSMutableArray<NSString *> *layouts;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id<HBDNavigator>> *actionNavigatorPairs;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id<HBDNavigator>> *layoutNavigatorPairs;

@end

@implementation HBDNavigatorRegistry

- (instancetype)init {
    if (self = [super init]) {
        _navigators = [NSMutableArray new];
        _layouts = [NSMutableArray new];
        _actionNavigatorPairs = [NSMutableDictionary new];
        _layoutNavigatorPairs = [NSMutableDictionary new];
    }
    
    [self registerNavigator:[HBDStackNavigator new]];
    [self registerNavigator:[HBDScreenNavigator new]];
    [self registerNavigator:[HBDTabNavigator new]];
    [self registerNavigator:[HBDDrawerNavigator new]];
    
    return self;
}

- (void)registerNavigator:(id<HBDNavigator>)navigator {
    [self.navigators insertObject:navigator atIndex:0];
    [self.layouts addObject:[navigator name]];
    
    for (NSString *action in [navigator supportActions]) {
        id<HBDNavigator> duplicated = [self.actionNavigatorPairs objectForKey:action];
        if (duplicated) {
            RCTLogError(@"%@ 想要注册的 action %@ 已经被 %@ 所注册", [navigator class], action, [duplicated class]);
        }
        [self.actionNavigatorPairs setObject:navigator forKey:action];
    }
    
    NSString *layout = [navigator name];
    id<HBDNavigator> duplicatedLayout = [self.layoutNavigatorPairs objectForKey:layout];
    if (duplicatedLayout) {
        RCTLogError(@"%@ 想要注册的 layout %@ 已经被 %@ 所注册", [navigator class], layout, [duplicatedLayout class]);
    }
    [self.layoutNavigatorPairs setObject:navigator forKey:layout];
}

- (id<HBDNavigator>)navigatorForAction:(NSString *)action {
    return [self.actionNavigatorPairs objectForKey:action];
}

- (id<HBDNavigator>)navigatorForLayout:(NSString *)layout {
    return [self.layoutNavigatorPairs objectForKey:layout];
}

- (NSArray<id<HBDNavigator>> *) allNavigators {
    return [self.navigators copy];
}

- (NSArray<NSString *> *) allLayouts {
    return [self.layouts copy];
}

@end
