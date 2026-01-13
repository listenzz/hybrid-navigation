#import "HBDDrawerController.h"

#import <UIKit/UIKit.h>

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

- (void)hbd_setNeedsUpdateNavigationBar;

@property(nonatomic, copy, readonly) NSString *sceneId;
@property(nonatomic, copy) NSString *presentingSceneId;
@property(nonatomic, assign) NSInteger resultCode;
@property(nonatomic, assign) NSInteger requestCode;
@property(nonatomic, copy) NSDictionary *resultData;

- (BOOL)canPresentViewController;

- (void)setResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data;

- (void)didReceiveResultCode:(NSInteger)resultCode resultData:(NSDictionary *)data requestCode:(NSInteger)requestCode;

- (HBDDrawerController *)drawerController;

- (NSString *)hbd_mode;

@end
