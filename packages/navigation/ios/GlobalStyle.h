#import <UIKit/UIKit.h>

@interface GlobalStyle : NSObject

+ (void)createWithOptions:(NSDictionary *)options;

+ (GlobalStyle *)globalStyle;

@property(nonatomic, strong, readonly) UIColor *screenBackgroundColor;
@property(nonatomic, assign) UIInterfaceOrientationMask interfaceOrientation;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (UIColor *)titleTextColorWithBarStyle:(UIBarStyle)barStyle;

- (UIColor *)tintColorWithBarStyle:(UIBarStyle)barStyle;

- (UIColor *)barTintColorWithBarStyle:(UIBarStyle)barStyle;

@end
