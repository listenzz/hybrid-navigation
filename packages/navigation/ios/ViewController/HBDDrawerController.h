#import <UIKit/UIKit.h>

@interface HBDDrawerController : UIViewController

@property(nonatomic, strong, readonly) UIViewController *contentController;
@property(nonatomic, strong, readonly) UIViewController *menuController;
@property(nonatomic, assign) BOOL menuInteractive;
@property(nonatomic, assign) CGFloat minDrawerMargin;
@property(nonatomic, assign) CGFloat maxDrawerWidth;

- (instancetype)initWithContentViewController:(UIViewController *)content menuViewController:(UIViewController *)menu;

- (void)openMenu;

- (void)closeMenu;

- (void)toggleMenu;

- (BOOL)isMenuOpened;

@end
