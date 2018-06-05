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

@protocol HBDModalContentSizeProvider <NSObject>

/**
 *  当浮层以 UIViewController 的形式展示（而非 UIView），并且使用 modalController 提供的默认布局时，则可通过这个方法告诉 modalController 当前浮层期望的大小
 *  @param  controller  当前的modalController
 *  @param  limitSize   浮层最大的宽高，由当前 modalController 的大小及 `contentViewMargins`、`maximumContentViewWidth` 决定
 *  @return 返回浮层在 `limitSize` 限定内的大小，如果业务自身不需要限制宽度/高度，则为 width/height 返回 `CGFLOAT_MAX` 即可
 */
- (CGSize)preferredContentSizeInModalViewController:(HBDModalViewController *)controller limitSize:(CGSize)limitSize;

@end

@interface HBDModalViewController : HBDViewController

@property(nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, strong) UIView *dimmingView;

/**
 *  设置`contentView`布局时与外容器的间距，默认为(20, 20, 20, 20)
 *  @warning 当设置了`layoutBlock`属性时，此属性不生效
 */
@property(nonatomic, assign) UIEdgeInsets contentViewMargins;

/**
 *  限制`contentView`布局时的最大宽度，默认为iPhone 6竖屏下的屏幕宽度减去`contentViewMargins`在水平方向的值，也即浮层在iPhone 6 Plus或iPad上的宽度以iPhone 6上的宽度为准。
 *  @warning 当设置了`layoutBlock`属性时，此属性不生效
 */
@property(nonatomic, assign) CGFloat maximumContentViewWidth;

/**
 *  要被弹出的浮层，适用于浮层以UIViewController的形式来管理的情况。
 *  @warning 当设置了`contentViewController`时，`contentViewController.view`会被当成`contentView`使用，因此不要再自行设置`contentView`
 *  @warning 注意`contentViewController`是强引用，容易导致循环引用，使用时请注意
 */
@property(nonatomic, strong) id<HBDModalContentSizeProvider> contentSizeProvider;

/**
 *  管理自定义的浮层布局，将会在浮层显示前、控件的容器大小发生变化时（例如横竖屏、来电状态栏）被调用
 *  @arg  containerBounds         浮层所在的父容器的大小，也即`self.view.bounds`
 *  @arg  keyboardHeight          键盘在当前界面里的高度，若无键盘，则为0
 *  @arg  contentViewDefaultFrame 不使用自定义布局的情况下的默认布局，会受`contentViewMargins`、`maximumContentViewWidth`、`contentView sizeThatFits:`的影响
 *
 *  @see contentViewMargins
 *  @see maximumContentViewWidth
 */
@property(nonatomic, copy) void (^layoutBlock)(CGRect containerBounds, CGRect contentViewDefaultFrame);

/**
 *  设置要使用的显示/隐藏动画的类型，默认为`QMUIModalPresentationAnimationStyleFade`。
 *  @warning 当使用了`showingAnimation`和`hidingAnimation`时，该属性无效
 */
@property(nonatomic, assign) HBDModalAnimationStyle animationStyle;

/**
 *  管理自定义的显示动画，需要管理的对象包括`contentView`和`dimmingView`，在`showingAnimation`被调用前，`contentView`已被添加到界面上。若使用了`layoutBlock`，则会先调用`layoutBlock`，再调用`showingAnimation`。在动画结束后，必须调用参数里的`completion` block。
 *  @arg  dimmingView         背景遮罩的View，请自行设置显示遮罩的动画
 *  @arg  containerBounds     浮层所在的父容器的大小，也即`self.view.bounds`
 *  @arg  keyboardHeight      键盘在当前界面里的高度，若无键盘，则为0
 *  @arg  contentViewFrame    动画执行完后`contentView`的最终frame，若使用了`layoutBlock`，则也即`layoutBlock`计算完后的frame
 *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些状态设置，务必调用。
 */
@property(nonatomic, copy) void (^showingAnimation)(UIView *dimmingView, CGRect containerBounds, CGRect contentViewFrame, void(^completion)(BOOL finished));

/**
 *  管理自定义的隐藏动画，需要管理的对象包括`contentView`和`dimmingView`，在动画结束后，必须调用参数里的`completion` block。
 *  @arg  dimmingView         背景遮罩的View，请自行设置隐藏遮罩的动画
 *  @arg  containerBounds     浮层所在的父容器的大小，也即`self.view.bounds`
 *  @arg  keyboardHeight      键盘在当前界面里的高度，若无键盘，则为0
 *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些清理工作，务必调用
 */
@property(nonatomic, copy) void (^hidingAnimation)(UIView *dimmingView, CGRect containerBounds, void(^completion)(BOOL finished));

/**
 *  请求重新计算浮层的布局
 */
- (void)updateLayout;

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

/// 专用于 HBDModalViewController 的 UIWindow，这样才能在`[[UIApplication sharedApplication] windows]`里方便地区分出来
@interface HBDModalWindow : UIWindow

@end


@interface UIViewController (HBDModalViewController)

@property(nonatomic, weak, readonly) HBDModalViewController *hbd_modalViewController;

@end

