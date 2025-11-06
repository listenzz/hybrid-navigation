//
//  HBDNativeEvent.m
//  HybridNavigation
//
//  Created by 李生 on 2025/11/2.
//

#import "HBDNativeEvent.h"
#import "HBDReactBridgeManager.h"
#import <React-RuntimeApple/ReactCommon/RCTHost.h>

@implementation HBDNativeEvent

+ (NSString *)moduleName { 
	return @"HBDNativeEvent";
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
	return std::make_shared<facebook::react::NativeEventSpecJSI>(params);
}

+ (HBDNativeEvent *)getInstance {
	HBDReactBridgeManager *manager = [HBDReactBridgeManager get];
	RCTHost *rctHost = manager.rctHost;
	HBDNativeEvent *emmiter = [[rctHost moduleRegistry] moduleForClass:self.class];
	return emmiter;
}

@end
