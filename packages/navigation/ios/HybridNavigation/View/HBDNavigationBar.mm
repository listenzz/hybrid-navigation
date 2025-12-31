#import "HBDNavigationBar.h"

#import "HBDUtils.h"
#import <React/RCTLog.h>

#define hairlineWidth (1.f/[UIScreen mainScreen].scale)

@interface HBDNavigationBar ()

@property(nonatomic, strong, readwrite) UIImageView *fakeShadowView;
@property(nonatomic, strong, readwrite) UIView *fakeBackgroundView;

@end

@implementation HBDNavigationBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha < 0.01) {
        return nil;
    }

    UIView *view = [super hitTest:point withEvent:event];
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	// RCTLogInfo(@"viewName:%@", viewName);

	NSArray *array = @[@"UINavigationBarContentView", @"UIButtonBarStackView", @"UIKit.NavigationBarContentView",  NSStringFromClass([self class])];
	if ([array containsObject:viewName] && self.fakeBackgroundView.alpha < 0.01) {
		return nil;
    }

    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fakeBackgroundView.frame = self.fakeBackgroundView.superview.bounds;
    self.fakeShadowView.frame = CGRectMake(0, CGRectGetHeight(self.fakeShadowView.superview.bounds) - hairlineWidth, CGRectGetWidth(self.fakeShadowView.superview.bounds), hairlineWidth);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    self.fakeBackgroundView.backgroundColor = barTintColor;
    [self makesureFakeView];
}

- (UIView *)fakeBackgroundView {
    if (!_fakeBackgroundView) {
        [super setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _fakeBackgroundView = [[UIView alloc] init];
        _fakeBackgroundView.userInteractionEnabled = NO;
        _fakeBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _fakeBackgroundView;
}

- (void)setTranslucent:(BOOL)translucent {
    // prevent default behavior
    [super setTranslucent:YES];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {

}

- (void)setShadowImage:(UIImage *)shadowImage {
    self.fakeShadowView.image = shadowImage;
    if (shadowImage) {
        self.fakeShadowView.backgroundColor = nil;
    } else {
        self.fakeShadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:77.0 / 255];
    }

}

- (UIImageView *)fakeShadowView {
    if (!_fakeShadowView) {
        [super setShadowImage:[UIImage new]];
        _fakeShadowView = [[UIImageView alloc] init];
        _fakeShadowView.userInteractionEnabled = NO;
        _fakeShadowView.contentScaleFactor = 1;
        _fakeShadowView.layer.allowsEdgeAntialiasing = YES;
    }
    return _fakeShadowView;
}

- (void)makesureFakeView {
    [UIView setAnimationsEnabled:NO];
    if (!self.fakeBackgroundView.superview) {
        [[self.subviews firstObject] insertSubview:self.fakeBackgroundView atIndex:0];
        self.fakeBackgroundView.frame = self.fakeBackgroundView.superview.bounds;
    }

    if (!self.fakeShadowView.superview) {
        [[self.subviews firstObject] insertSubview:self.fakeShadowView aboveSubview:self.fakeBackgroundView];
        self.fakeShadowView.frame = CGRectMake(0, CGRectGetHeight(self.fakeShadowView.superview.bounds) - hairlineWidth, CGRectGetWidth(self.fakeShadowView.superview.bounds), hairlineWidth);
    }
    [UIView setAnimationsEnabled:YES];
}

- (UILabel *)backButtonLabel {
	UIView *navigationBarContentView = [self getViewFromContext:self withKeyPath:@"visualProvider.contentView"];
    __block UILabel *backButtonLabel = nil;
    [navigationBarContentView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView *_Nonnull subview, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([subview isKindOfClass:NSClassFromString(@"_UIButtonBarButton")]) {
			UIButton *titleButton = (UIButton *)[self getViewFromContext:subview withKeyPath:@"visualProvider.titleButton"];
            backButtonLabel = titleButton.titleLabel;
            *stop = YES;
        }
    }];
    return backButtonLabel;
}

// 兼容 iOS26
- (UIView *)getViewFromContext:(id)context withKeyPath:(NSString *)keyPath {
	if (!context || !keyPath) {
		return nil;
	}

	if (@available(iOS 26.0, *)) {
		// 如果 context 是 UIView，先尝试通过遍历 subviews 查找包含 "ContentView" 的视图
		if ([context isKindOfClass:[UIView class]]) {
			UIView *view = (UIView *)context;
			__block UIView *contentView = nil;

			// 使用标准的 enumerateObjectsUsingBlock 替代 qmui_firstMatchWithBlock
			[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
				if ([NSStringFromClass(item.class) containsString:@"ContentView"]) {
					contentView = item;
					*stop = YES;
				}
			}];

			if (contentView) return contentView;
		}

		// Xcode 26 编译在 iOS 26 上时，无法用以前的 KVC 方式获取 contentView，所以改为通过 Ivar 获取
		// 解析 keyPath，获取 provider key（例如从 "visualProvider.contentView" 中获取 "visualProvider"）
		NSArray *components = [keyPath componentsSeparatedByString:@"."];
		if (components.count > 0) {
			NSString *providerKey = components.firstObject;
			NSObject *provider = [context valueForKey:providerKey];

			if (provider && components.count > 1) {
				NSString *targetKey = components.lastObject;
				__block UIView *result = nil;

				// 使用 Runtime API 直接获取 Ivar 列表，替代 qmui_enumrateIvarsUsingBlock
				unsigned int ivarCount = 0;
				Ivar *ivars = class_copyIvarList([provider class], &ivarCount);

				if (ivars) {
					for (unsigned int i = 0; i < ivarCount && !result; i++) {
						Ivar ivar = ivars[i];
						const char *ivarName = ivar_getName(ivar);

						if (ivarName) {
							NSString *ivarNameString = [NSString stringWithUTF8String:ivarName];
							// 检查 ivar 名称是否包含 targetKey
							if ([ivarNameString containsString:targetKey]) {
								// 直接使用 object_getIvar 获取 Ivar 值，替代 getObjectIvarValue
								result = object_getIvar(provider, ivar);
							}
						}
					}
					free(ivars);
				}

				return result;
			}
		}
	}

	// 在 iOS 26.0 以下，直接通过 KVC 获取
	return [context valueForKeyPath:keyPath];
}

@end

@implementation UILabel (NavigationBarTransition)

- (UIColor *)hbd_specifiedTextColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_specifiedTextColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(hbd_specifiedTextColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [self class];
        hbd_exchangeImplementations(clazz, @selector(setAttributedText:), @selector(hbd_setAttributedText:));
    });
}

- (void)hbd_setAttributedText:(NSAttributedString *)attributedText {
    if (self.hbd_specifiedTextColor) {
        NSMutableAttributedString *mutableAttributedText = [attributedText isKindOfClass:NSMutableAttributedString.class] ? attributedText : [attributedText mutableCopy];
        [mutableAttributedText addAttributes:@{NSForegroundColorAttributeName: self.hbd_specifiedTextColor} range:NSMakeRange(0, mutableAttributedText.length)];
        attributedText = mutableAttributedText;
    }
    [self hbd_setAttributedText:attributedText];
}

@end
