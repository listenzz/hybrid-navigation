//
//  HBDDrawerController.h
//
//  Created by Listen on 2018/1/25.
//

#import <UIKit/UIKit.h>

@interface HBDDrawerController : UIViewController

@property (nonatomic, strong, readonly) UIViewController *contentController;
@property (nonatomic, strong, readonly) UIViewController *menuController;

- (void)setContentViewController:(UIViewController *)contentViewController;
- (void)setMenuViewController:(UIViewController *)menuViewController;

- (void)openMenu;
- (void)closeMenu;
- (void)toggleMenu;
- (BOOL)isMenuOpened;

@end
