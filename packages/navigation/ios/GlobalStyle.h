#import <UIKit/UIKit.h>

@interface GlobalStyle : NSObject

+ (void)createWithOptions:(NSDictionary *)options;

+ (GlobalStyle *)globalStyle;

@property(nonatomic, strong, readonly) UIColor *screenBackgroundColor;
@property(nonatomic, assign, readonly) UIBarStyle statusBarStyle;
@property(nonatomic, assign) UIInterfaceOrientationMask interfaceOrientation;

- (instancetype)initWithOptions:(NSDictionary *)options;

@end
