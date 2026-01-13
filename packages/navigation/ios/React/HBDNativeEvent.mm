#import "HBDNativeEvent.h"
#import "HBDReactBridgeManager.h"
#import <React-RuntimeApple/ReactCommon/RCTHost.h>
#import <React/RCTLog.h>

@implementation HBDNativeEvent

+ (NSString *)moduleName { 
	return @"HBDNativeEvent";
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
	return std::make_shared<facebook::react::NativeEventSpecJSI>(params);
}

- (void)initialize {
	RCTLogInfo(@"[Navigation] HBDNativeEvent#initialize");
}

- (void)invalidate {
	RCTLogInfo(@"[Navigation] HBDNativeEvent#invalidate");
}

+ (HBDNativeEvent *)getInstance {
	HBDReactBridgeManager *manager = [HBDReactBridgeManager get];
	RCTHost *rctHost = manager.rctHost;
	HBDNativeEvent *emmiter = [[rctHost moduleRegistry] moduleForClass:self.class];
	return emmiter;
}

@end
