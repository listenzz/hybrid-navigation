#import <UIKit/UIKit.h>

@interface HBDNavigationBar : UINavigationBar

@property(nonatomic, strong, readonly) UIImageView *fakeShadowView;
@property(nonatomic, strong, readonly) UIView *fakeBackgroundView;
@property(nonatomic, strong, readonly) UILabel *backButtonLabel;

@end

@interface UILabel (NavigationBarTransition)

@property(nonatomic, strong) UIColor *hbd_specifiedTextColor;

@end
