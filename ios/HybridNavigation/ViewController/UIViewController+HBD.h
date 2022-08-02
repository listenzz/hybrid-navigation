#import <UIKit/UIKit.h>
#import "HBDDrawerController.h"

typedef void(^HBDDidShowActionBlock)(void);

typedef void(^HBDDidHideActionBlock)(void);

@interface UIViewController (HBD)

@property(nonatomic, assign) UIBarStyle hbd_barStyle;
@property(nonatomic, strong) UIColor *hbd_barTintColor;
@property(nonatomic, strong) UIColor *hbd_tintColor;
@property(nonatomic, strong) NSDictionary *hbd_titleTextAttributes;
@property(nonatomic, assign) float hbd_barAlpha;
@property(nonatomic, assign) BOOL hbd_barHidden;
@property(nonatomic, assign) BOOL hbd_barShadowHidden;
@property(nonatomic, assign) BOOL hbd_backInteractive;
@property(nonatomic, assign) BOOL hbd_swipeBackEnabled;
@property(nonatomic, assign, readonly) float hbd_barShadowAlpha;
@property(nonatomic, assign) BOOL hbd_statusBarHidden;

@property(nonatomic, assign) BOOL hbd_viewAppeared;
@property(nonatomic, copy) HBDDidShowActionBlock didShowActionBlock;
@property(nonatomic, copy) HBDDidHideActionBlock didHideActionBlock;

- (void)hbd_setNeedsUpdateNavigationBar;

@property(nonatomic, assign) BOOL hbd_extendedLayoutDidSet;

@property(nonatomic, copy, readonly) NSString *sceneId;
@property(nonatomic, assign) NSInteger resultCode;
@property(nonatomic, assign) NSInteger requestCode;
@property(nonatomic, copy) NSDictionary *resultData;

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

- (HBDDrawerController *)drawerController;

- (void)hbd_updateTabBarItem:(NSDictionary *)options;

- (NSString *)hbd_mode;

@end
