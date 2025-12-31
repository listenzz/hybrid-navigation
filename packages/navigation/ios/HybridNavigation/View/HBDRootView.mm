#import "HBDRootView.h"

#import "RCTConstants.h"
#import "RCTDefines.h"
#import "RCTSurface.h"
#import "RCTSurfaceDelegate.h"
#import "RCTSurfaceView.h"
#import "RCTUtils.h"

@interface HBDRootView ()

@property (nonatomic, assign) BOOL isSurfaceViewVisible;
@property (nonatomic, assign) RCTSurfaceSizeMeasureMode sizeMeasureMode;

@end

@implementation HBDRootView {
	UIView *_Nullable _surfaceView;
	RCTSurfaceStage _stage;
}

RCT_NOT_IMPLEMENTED(-(instancetype)init)
RCT_NOT_IMPLEMENTED(-(instancetype)initWithFrame : (CGRect)frame)
RCT_NOT_IMPLEMENTED(-(nullable instancetype)initWithCoder : (NSCoder *)coder)

- (instancetype)initWithSurface:(id<RCTSurfaceProtocol>)surface {
	return [self initWithSurface:surface sizeMeasureMode:RCTSurfaceSizeMeasureModeWidthExact | RCTSurfaceSizeMeasureModeHeightExact];
}

- (instancetype)initWithSurface:(id<RCTSurfaceProtocol>)surface
				sizeMeasureMode:(RCTSurfaceSizeMeasureMode)sizeMeasureMode {
	if (self = [super initWithFrame:CGRectZero]) {
		_surface = surface;
		_sizeMeasureMode = sizeMeasureMode;
		_surface.delegate = self;
		_stage = surface.stage;
		[self _updateViews];
	}

	return self;
}

- (void)dealloc {
	[_surface stop];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *hitView = [super hitTest:point withEvent:event];
	if (self.passThroughTouches && [self shouldPassTouches:hitView]) {
		return nil;
	}
	return hitView;
}

- (BOOL)shouldPassTouches:(UIView *)hitView {
	if (!hitView) {
		return true;
	}

	// RCTRootComponentView
	if (hitView == _surfaceView || hitView == [_surfaceView.subviews firstObject]) {
		return true;
	}

	return false;
}

- (NSDictionary *)appProperties {
	return _surface.properties;
}

- (void)setAppProperties:(NSDictionary *)appProperties {
	[_surface setProperties:appProperties];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGSize minimumSize;
	CGSize maximumSize;

	RCTSurfaceMinimumSizeAndMaximumSizeFromSizeAndSizeMeasureMode(
	  self.bounds.size, _sizeMeasureMode, &minimumSize, &maximumSize);
	CGRect windowFrame = [self.window convertRect:self.frame fromView:self.superview];

	[_surface setMinimumSize:minimumSize maximumSize:maximumSize viewportOffset:windowFrame.origin];
}

- (CGSize)intrinsicContentSize {
	if (RCTSurfaceStageIsPreparing(_stage)) {
		return CGSizeZero;
	}

	return _surface.intrinsicSize;
}

- (CGSize)sizeThatFits:(CGSize)size {
	if (RCTSurfaceStageIsPreparing(_stage)) {
		return CGSizeZero;
	}

	CGSize minimumSize;
	CGSize maximumSize;

	RCTSurfaceMinimumSizeAndMaximumSizeFromSizeAndSizeMeasureMode(size, _sizeMeasureMode, &minimumSize, &maximumSize);

	return [_surface sizeThatFitsMinimumSize:minimumSize maximumSize:maximumSize];
}

- (void)setStage:(RCTSurfaceStage)stage {
	if (stage == _stage) {
		return;
	}

	BOOL shouldInvalidateLayout = RCTSurfaceStageIsRunning(stage) != RCTSurfaceStageIsRunning(_stage) ||
	  RCTSurfaceStageIsPreparing(stage) != RCTSurfaceStageIsPreparing(_stage);

	_stage = stage;

	if (shouldInvalidateLayout) {
		[self _invalidateLayout];
		[self _updateViews];
	}
}

- (void)setSizeMeasureMode:(RCTSurfaceSizeMeasureMode)sizeMeasureMode {
	if (sizeMeasureMode == _sizeMeasureMode) {
		return;
	}

	_sizeMeasureMode = sizeMeasureMode;
	[self _invalidateLayout];
}


#pragma mark - isSurfaceViewVisible

- (void)setIsSurfaceViewVisible:(BOOL)visible {
	if (_isSurfaceViewVisible == visible) {
		return;
	}

	_isSurfaceViewVisible = visible;

	if (visible) {
		_surfaceView = _surface.view;
		_surfaceView.frame = self.bounds;
		_surfaceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_surfaceView];
	} else {
		[_surfaceView removeFromSuperview];
		_surfaceView = nil;
	}
}

#pragma mark - UITraitCollection updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	[super traitCollectionDidChange:previousTraitCollection];

	if (RCTSharedApplication().applicationState == UIApplicationStateBackground) {
		return;
	}

	[[NSNotificationCenter defaultCenter]
	  postNotificationName:RCTUserInterfaceStyleDidChangeNotification
					object:self
				  userInfo:@{
					RCTUserInterfaceStyleDidChangeNotificationTraitCollectionKey : self.traitCollection,
				  }];
}

#pragma mark - Private stuff

- (void)_invalidateLayout {
	[self invalidateIntrinsicContentSize];
	[self.superview setNeedsLayout];
}

- (void)_updateViews {
	self.isSurfaceViewVisible = RCTSurfaceStageIsRunning(_stage);
}

- (void)didMoveToWindow {
	[super didMoveToWindow];
	[self _updateViews];
}

#pragma mark - RCTSurfaceDelegate

- (void)surface:(__unused RCTSurface *)surface didChangeStage:(RCTSurfaceStage)stage {
	RCTExecuteOnMainQueue(^{
		[self setStage:stage];
	});
}

- (void)surface:(__unused RCTSurface *)surface didChangeIntrinsicSize:(__unused CGSize)intrinsicSize {
	RCTExecuteOnMainQueue(^{
		[self _invalidateLayout];
	});
}

@end
