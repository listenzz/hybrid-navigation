#import "HBDViewController.h"

@class RCTRootView;

@interface HBDReactViewController : HBDViewController

@property(nonatomic, strong, readonly) RCTRootView *rootView;

- (void)signalFirstRenderComplete;

@end
