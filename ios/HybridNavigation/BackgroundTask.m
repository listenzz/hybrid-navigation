#import "BackgroundTask.h"

@implementation BackgroundTask

static NSString *const BACKGROUND_TASK_EVENT = @"BACKGROUND_TASK_EVENT";

RCT_EXPORT_MODULE(BackgroundTask)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{
        @"BACKGROUND_TASK_EVENT": BACKGROUND_TASK_EVENT,
    };
}

- (NSArray<NSString *> *)supportedEvents {
    return @[ BACKGROUND_TASK_EVENT ];
}

RCT_EXPORT_METHOD(scheduleTask) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self sendEventWithName:BACKGROUND_TASK_EVENT body:@{}];
        [self sendEventWithName:BACKGROUND_TASK_EVENT body:@{}];
        [self sendEventWithName:BACKGROUND_TASK_EVENT body:@{}];
    });
}


@end
