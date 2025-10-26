package com.reactnative.hybridnavigation;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.KeyEvent;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;
import com.facebook.react.util.AndroidVersion;
import com.navigation.androidx.AwesomeActivity;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.Style;

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity, ReactManager.ReactModuleRegisterListener {

	protected static final String TAG = "Navigation";

	private final ReactAppCompatActivityDelegate mDelegate;

	private final OnBackPressedCallback mBackPressedCallback =
		new OnBackPressedCallback(true) {
			@Override
			public void handleOnBackPressed() {
				setEnabled(false);
				onBackPressed();
				setEnabled(true);
			}
		};

	protected ReactAppCompatActivity() {
		mDelegate = createReactActivityDelegate();
	}

	protected ReactAppCompatActivityDelegate createReactActivityDelegate() {
		return new ReactAppCompatActivityDelegate(this, ReactManager.get());
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (savedInstanceState != null) {
			FLog.i(TAG, "ReactAppCompatActivity#re-create");
		}

		mDelegate.onCreate(savedInstanceState);
		if (AndroidVersion.isAtLeastTargetSdk36(this)) {
			getOnBackPressedDispatcher().addCallback(this, mBackPressedCallback);
		}

		ReactManager reactManager = getReactManager();
		reactManager.addReactModuleRegisterListener(this);
		if (isReactModuleRegisterCompleted()) {
			onReactModuleRegisterCompleted();
		}
	}

	public void inflateStyle() {
		Style style = getStyle();
		GlobalStyle globalStyle = Garden.getGlobalStyle();
		if (style != null && !isFinishing()) {
			FLog.i(TAG, "ReactAppCompatActivity#inflateStyle");
			globalStyle.inflateStyle(this, style);
		}
	}

	@Override
	protected void onDestroy() {
		getReactManager().removeReactModuleRegisterListener(this);
		super.onDestroy();
		mDelegate.onDestroy();
	}

	@Override
	public void onReactModuleRegisterCompleted() {
		FLog.i(TAG, "ReactAppCompatActivity#onReactModuleRegisterCompleted");
		ReactManager reactManager = getReactManager();
		ReactContext reactContext = reactManager.getCurrentReactContext();
		if (isResumed && reactContext != null && reactContext.getCurrentActivity() == null) {
			mDelegate.onResume();
		}
		inflateStyle();
		Fragment fragment = getSupportFragmentManager().findFragmentById(android.R.id.content);
		if (fragment == null) {
			createMainComponent();
		}
	}

	private void createMainComponent() {
		onCreateMainComponent();
	}

	protected void onCreateMainComponent() {
		ReactManager reactManager = getReactManager();
		if (getMainComponentName() != null) {
			AwesomeFragment fragment = reactManager.createFragment(getMainComponentName());
			ReactStackFragment stackFragment = new ReactStackFragment();
			stackFragment.setRootFragment(fragment);
			setActivityRootFragment(stackFragment);
			return;
		}

		if (reactManager.hasPendingLayout()) {
			FLog.i(TAG, "Set root Fragment from pending layout when create main component");
			setActivityRootFragment(reactManager.getPendingLayout());
			return;
		}

		if (reactManager.hasStickyLayout()) {
			FLog.i(TAG, "Set root Fragment from sticky layout when create main component");
			setActivityRootFragment(reactManager.getStickyLayout());
			return;
		}

		if (reactManager.hasRootLayout()) {
			FLog.i(TAG, "Set root Fragment from last root layout when create main component");
			setActivityRootFragment(reactManager.getRootLayout());
			return;
		}

		FLog.w(TAG, "No layout to set when create main component");
	}

	protected String getMainComponentName() {
		return null;
	}

	protected void setActivityRootFragment(ReadableMap layout) {
		ReactManager reactManager = getReactManager();
		AwesomeFragment fragment = reactManager.createFragment(layout);
		if (fragment == null) {
			throw new IllegalArgumentException("无法创建 Fragment. " + layout);
		}
		setActivityRootFragment(fragment);
	}

	@Override
	protected void setActivityRootFragmentSync(AwesomeFragment fragment) {
		ReactManager reactManager = getReactManager();
		NativeEvent.getInstance().emitWillSetRoot();
		super.setActivityRootFragmentSync(fragment);
		reactManager.setViewHierarchyReady(true);
		Callback callback = reactManager.getPendingCallback();
		if (callback != null) {
			callback.invoke(null, true);
			reactManager.setPendingLayout(null, null);
		}
		NativeEvent.getInstance().emitDidSetRoot();
	}

	boolean isResumed = false;

	@Override
	protected void onResume() {
		super.onResume();
		isResumed = true;
		mDelegate.onResume();

		ReactManager reactManager = getReactManager();
		if (reactManager.hasPendingLayout()) {
			FLog.i(TAG, "Set root Fragment from pending layout when resume.");
			setActivityRootFragment(reactManager.getPendingLayout());
		}
	}

	@Override
	protected void onPause() {
		isResumed = false;
		mDelegate.onPause();
		super.onPause();
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		mDelegate.onActivityResult(requestCode, resultCode, data);
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		return mDelegate.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		return mDelegate.onKeyUp(keyCode, event) || super.onKeyUp(keyCode, event);
	}

	@Override
	public boolean onKeyLongPress(int keyCode, KeyEvent event) {
		return mDelegate.onKeyLongPress(keyCode, event) || super.onKeyLongPress(keyCode, event);
	}

	@Override
	public void onBackPressed() {
		if (!mDelegate.onBackPressed()) {
			super.onBackPressed();
		}
	}

	@Override
	public void invokeDefaultOnBackPressed() {
		scheduleTaskAtStarted(ReactAppCompatActivity.super::onBackPressed);
	}

	@Override
	public void onNewIntent(Intent intent) {
		if (!mDelegate.onNewIntent(intent)) {
			super.onNewIntent(intent);
		}
	}

	@Override
	protected void onUserLeaveHint() {
		super.onUserLeaveHint();
		mDelegate.onUserLeaveHint();
	}

	@Override
	public void requestPermissions(@NonNull String[] permissions, int requestCode, PermissionListener listener) {
		mDelegate.requestPermissions(permissions, requestCode, listener);
	}

	@Override
	public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
		mDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
		super.onRequestPermissionsResult(requestCode, permissions, grantResults);
	}

	public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		this.mDelegate.onWindowFocusChanged(hasFocus);
	}

	public void onConfigurationChanged(@NonNull Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		this.mDelegate.onConfigurationChanged(newConfig);
	}

	@NonNull
	protected ReactManager getReactManager() {
		return mDelegate.getReactManager();
	}

	protected final ReactContext getCurrentReactContext() {
		return mDelegate.getCurrentReactContext();
	}

	protected boolean isReactModuleRegisterCompleted() {
		return getReactManager().isReactModuleRegisterCompleted();
	}
}
