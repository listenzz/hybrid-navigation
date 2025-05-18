#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ON_COMPONENT_RESULT;
extern NSString *const ON_BAR_BUTTON_ITEM_CLICK;
extern NSString *const ON_COMPONENT_APPEAR;
extern NSString *const ON_COMPONENT_DISAPPEAR;
extern NSString *const EVENT_SWITCH_TAB;
extern NSString *const EVENT_NAVIGATION;
extern NSString *const EVENT_DID_SET_ROOT;
extern NSString *const EVENT_WILL_SET_ROOT;
extern NSString *const KEY_REQUEST_CODE;
extern NSString *const KEY_RESULT_CODE;
extern NSString *const KEY_RESULT_DATA;
extern NSString *const KEY_SCENE_ID;
extern NSString *const KEY_MODULE_NAME;
extern NSString *const KEY_INDEX;
extern NSString *const KEY_ACTION;
extern NSString *const KEY_ON;

@interface HBDEventEmitter : RCTEventEmitter

+ (void)sendEvent:(NSString *)eventName data:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
