//
//  HBDModalViewController.h
//  NavigationHybrid
//
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HBDViewController.h"

typedef NS_ENUM(NSUInteger, HBDModalAnimationStyle) {
    HBDModalAnimationStyleFade,    // 渐现渐隐，默认
    HBDModalAnimationStylePopup,   // 从中心点弹出
    HBDModalAnimationStyleSlide    // 从下往上升起
};

@class HBDModalViewController;

@interface HBDModalViewController : HBDViewController

@property(nonatomic, assign, readonly, getter=isBeingHidden) BOOL beingHidden;
@property(nonatomic, weak, readonly) UIWindow *previousKeyWindow;

@property(nonatomic, strong) UIViewController *contentViewController;

/**
 * 等同 contentViewController.view
 */
@property (nonatomic, strong, readonly) UIView *contentView;

/**
 * 黑色遮罩
 */
@property (nonatomic, strong) UIView *dimmingView;

/**
 *  设置`contentView`布局时与外容器的间距，默认为(20, 20, 20, 20)
 *  @warning 当设置了`layoutBlock`属性时，此属性不生效
 */
@property(nonatomic, assign) UIEdgeInsets contentViewMargins;

/**
 *  限制`contentView`布局时的最大宽度，默认为iPhone 6竖屏下的屏幕宽度减去`contentViewMargins`在水平方向的值，也即浮层在iPhone 6 Plus或iPad上的宽度以iPhone 6上的宽度为准。
 *  @warning 当设置了`layoutBlock`属性时，此属性不生效re
 */
@property(nonatomic, assign) CGFloat maximumContentViewWidth;

/**
 * 测量 contentView 的大小
 * @arg limitSize contentView size 范围
 */
@property(nonatomic, assign) CGSize (^measureBlock)(HBDModalViewController *modalViewController, CGSize limitSize);

/**
 *  管理自定义的浮层布局，将会在浮层显示前、控件的容器大小发生变化时（例如横竖屏、来电状态栏）被调用
 *  @arg  modalViewController
 *  @arg  contentViewDefaultFrame 不使用自定义布局的情况下的默认布局，会受`contentViewMargins`、`maximumContentViewWidth`、`contentView sizeThatFits:`的影响
 *
 *  @see contentViewMargins
 *  @see maximumContentViewWidth
 */
@property(nonatomic, copy) void (^layoutBlock)(HBDModalViewController *modalViewController, CGRect contentViewDefaultFrame);

/**
 *  设置要使用的显示/隐藏动画的类型，默认为`HBDModalAnimationStyleFade`。
 *  @warning 当使用了`showingAnimation`和`hidingAnimation`时，该属性无效
 */
@property(nonatomic, assign) HBDModalAnimationStyle animationStyle;

/**
 *  管理自定义的显示动画，需要管理的对象包括`contentView`和`dimmingView`，在`showingAnimation`被调用前，`contentView`已被添加到界面上。若使用了`layoutBlock`，则会先调用`layoutBlock`，再调用`showingAnimation`。在动画结束后，必须调用参数里的`completion` block。
 *  @arg  modalViewController
 *  @arg  contentViewFrame    动画执行完后`contentView`的最终frame，若使用了`layoutBlock`，则也即`layoutBlock`计算完后的frame
 *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些状态设置，务必调用。
 */
@property(nonatomic, copy) void (^showingAnimation)(HBDModalViewController *modalViewController, CGRect contentViewFrame, void(^completion)(BOOL finished));

/**
 *  管理自定义的隐藏动画，需要管理的对象包括`contentView`和`dimmingView`，在动画结束后，必须调用参数里的`completion` block。
 *  @arg  modalViewController
 *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些清理工作，务必调用
 */
@property(nonatomic, copy) void (^hidingAnimation)(HBDModalViewController *modalViewController, void(^completion)(BOOL finished));

/**
 * modal 将要销毁时的回掉
 */
@property(nonatomic, copy) void (^willDismissBlock)(HBDModalViewController *modalViewController);

/**
 *  请求重新计算浮层的布局
 */
- (void)updateLayout;

@end

/// 专用于 HBDModalViewController 的 UIWindow，这样才能在`[[UIApplication sharedApplication] windows]`里方便地区分出来
@interface HBDModalWindow : UIWindow

@end

@interface UIViewController (HBDModalViewController)

@property(nonatomic, weak, readonly) HBDModalViewController *hbd_modalViewController;

@property(nonatomic, strong, readonly) UIViewController *hbd_targetViewController;

@property(nonatomic, weak, readonly) UIViewController *hbd_popupViewController;

/// 把参数 vc 作为 contentViewController 包裹在 HBDModalViewController 中进行显示。
/// vc 可以通过 hbd_modalViewController 访问到包裹它的 HBDModalViewController。
/// vc 可以通过 hbd_targetViewController 访问到此方法的调用者。
/// 此方法的调用者可以通过 hbd_popupViewController 访问到 vc，也就是 HBDModalViewController 的 contentViewController。
- (void)hbd_showViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)hbd_hideViewControllerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

