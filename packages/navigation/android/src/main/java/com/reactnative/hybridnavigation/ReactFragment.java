package com.reactnative.hybridnavigation;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

import android.annotation.SuppressLint;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.facebook.common.logging.FLog;
import com.facebook.react.ReactHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.interfaces.fabric.ReactSurface;
import com.navigation.androidx.Style;

public class ReactFragment extends HybridFragment implements ReactManager.ReactBridgeReloadListener {

	protected static final String TAG = "Navigation";

	private HBDRootView reactRootView;

	private ReactSurface reactSurface;
	private ReactSurface reactTitleView;
	private boolean firstRenderCompleted;

	@Nullable
	@Override
	public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.nav_fragment_react, container, false);
		reactRootView = view.findViewById(R.id.react_content);
		if (isReactModuleRegisterCompleted()) {
			mountReactView();
		}
		return view;
	}

	@Override
	public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);
		// 这个时候 toolbar 才创建好
		initReactTitleView();
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		unmountReactView();
		reactRootView = null;
	}

	@Override
	public void onStop() {
		super.onStop();
		if (isRemoving() && forceScreenLandscape()) {
			unmountReactView();
		}
	}

	@Override
	protected boolean extendedLayoutIncludesToolbar() {
		int color = mStyle.getToolbarBackgroundColor();
		float alpha = mStyle.getToolbarAlpha();
		Garden garden = getGarden();
		return Color.alpha(color) < 255 || alpha < 1.0 || garden.toolbarHidden || garden.extendedLayoutIncludesTopBar;
	}

	@Override
	protected void onCustomStyle(@NonNull Style style) {
		super.onCustomStyle(style);
		if (shouldPassThroughTouches()) {
			style.setScrimAlpha(0);
		}
	}

	@SuppressLint("SourceLockedOrientationActivity")
	@Override
	public void onResume() {
		super.onResume();
		if (isViewReady()) {
			sendViewAppearEvent(true);
		}

		if (!forceScreenLandscape() &&
			!Navigator.MODE_MODAL.equals(Navigator.Util.getMode(this)) &&
			requireActivity().getRequestedOrientation() != ActivityInfo.SCREEN_ORIENTATION_PORTRAIT) {
			requireView().clearAnimation();
			requireActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		}

		if (forceScreenLandscape()) {
			requireActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
		}
	}

	@Override
	public void onPause() {
		super.onPause();
		if (isViewReady()) {
			sendViewAppearEvent(false);
		}
	}

	private boolean isViewReady() {
		if (reactSurface == null) {
			return false;
		}
		return firstRenderCompleted;
	}

	private boolean reactViewAppeared = false;

	private void sendViewAppearEvent(boolean appear) {
		if (!isReactModuleRegisterCompleted()) {
			return;
		}

		// 当从前台进入后台时，不会触发 disappear, 这和 iOS 保持一致
		ReactContext reactContext = getCurrentReactContext();
		boolean isResumed = reactContext != null && reactContext.getLifecycleState() == LifecycleState.RESUMED;
		if (!isResumed) {
			return;
		}

		if (reactViewAppeared == appear) {
			return;
		}
		reactViewAppeared = appear;

		Bundle bundle = new Bundle();
		bundle.putString("sceneId", getSceneId());
		NativeEvent nativeEvent = NativeEvent.getInstance();
		if (appear) {
			nativeEvent.emitOnComponentAppear(Arguments.fromBundle(bundle));
		} else {
			nativeEvent.emitOnComponentDisappear(Arguments.fromBundle(bundle));
		}
	}

	@Override
	public void onReload() {
		unmountReactView();
	}

	private void mountReactView() {
		initReactRootView();
		getReactManager().addReactBridgeReloadListener(this);
	}

	private void unmountReactView() {
		getReactManager().removeReactBridgeReloadListener(this);

		boolean canStopSurface = false;
		ReactContext reactContext = getCurrentReactContext();
		if (reactContext != null && reactContext.hasActiveReactInstance()) {
			canStopSurface = true;
		}

		if (reactSurface != null) {
			FLog.w(TAG, "销毁页面-：" + getModuleName());
			reactSurface = null;
		}

		if (reactRootView != null) {
			reactRootView.clearSurface(canStopSurface);
		}

		if (reactTitleView != null) {
			if (canStopSurface) {
				reactTitleView.stop();
			}
			reactTitleView = null;
		}
	}

	@Override
	protected boolean onBackPressed() {
		ReactHost reactHost = getReactManager().getReactHost();
		if (getShowsDialog()) {
			reactHost.onBackPressed();
			return true;
		}
		return super.onBackPressed();
	}

	public void signalFirstRenderComplete() {
		if (firstRenderCompleted) {
			return;
		}
		firstRenderCompleted = true;

		if (isViewReady() && isResumed()) {
			sendViewAppearEvent(true);
		}
	}

	public boolean isFirstRenderCompleted() {
		return firstRenderCompleted;
	}

	@Override
	public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
		super.onFragmentResult(requestCode, resultCode, data);
		Bundle result = new Bundle();
		result.putInt("requestCode", requestCode);
		result.putInt("resultCode", resultCode);
		result.putBundle("resultData", data);
		result.putString("sceneId", getSceneId());
		NativeEvent.getInstance().emitOnResult(Arguments.fromBundle(result));
	}

	private void initReactRootView() {
		ReactHost reactHost = getReactManager().getReactHost();
		ReactSurface reactSurface = reactHost.createSurface(requireContext(), getModuleName(), getProps());
		this.reactSurface = reactSurface;

		HBDRootView rootView = reactRootView;
		if (rootView == null) {
			throw new IllegalStateException("[Navigation] HBDRootView 还没有创建。");
		}
		rootView.setPassThroughTouches(shouldPassThroughTouches());
		rootView.setAppProperties(getProps());
		rootView.setSurface(reactSurface);
	}

	private void initReactTitleView() {
		if (getToolbar() == null) {
			return;
		}

		Bundle titleItem = getOptions().getBundle("titleItem");
		if (titleItem == null) {
			return;
		}

		String moduleName = titleItem.getString("moduleName");
		if (moduleName == null) {
			return;
		}

		if (!isReactModuleRegisterCompleted()) {
			throw new IllegalStateException("[Navigation] React Component 还没有注册完毕。");
		}

		String fitting = titleItem.getString("layoutFitting");
		boolean expanded = "expanded".equals(fitting);
		ReactHost reactHost = getReactManager().getReactHost();
		ReactSurface reactSurface = reactHost.createSurface(requireContext(), moduleName, getProps());
		reactTitleView = reactSurface;
		Toolbar.LayoutParams layoutParams = createTitleLayoutParams(expanded);
		Toolbar toolbar = getToolbar();
		toolbar.addView(reactSurface.getView(), layoutParams);
		reactSurface.start();
	}

	@Override
	public void setAppProperties(@NonNull Bundle props) {
		super.setAppProperties(props);
		if (isReactModuleRegisterCompleted() && reactRootView != null) {
			reactRootView.setAppProperties(getProps());
		}
	}

	@NonNull
	private Toolbar.LayoutParams createTitleLayoutParams(boolean expanded) {
		if (expanded) {
			return new Toolbar.LayoutParams(MATCH_PARENT, MATCH_PARENT, Gravity.CENTER);
		}
		return new Toolbar.LayoutParams(WRAP_CONTENT, WRAP_CONTENT, Gravity.CENTER);
	}

	@Override
	public String getDebugTag() {
		return "[" + getModuleName() + "]";
	}

}
