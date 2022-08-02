#import <UIKit/UIKit.h>

typedef void(^HBDButtonActionBlock)(void);

@interface HBDBarButtonItem : UIBarButtonItem

@property(nonatomic, copy) HBDButtonActionBlock actionBlock;

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style;

- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style;

@end


@interface HBDBarButton : UIButton

@property(nonatomic) UIEdgeInsets alignmentRectInsetsOverride;

@end
