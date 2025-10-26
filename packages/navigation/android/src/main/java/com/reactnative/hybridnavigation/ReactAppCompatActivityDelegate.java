package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.view.KeyEvent;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.facebook.common.logging.FLog;
import com.facebook.infer.annotation.Assertions;
import com.facebook.react.ReactHost;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.common.ReactConstants;
import com.facebook.react.devsupport.DoubleTapReloadRecognizer;
import com.facebook.react.devsupport.interfaces.DevSupportManager;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionListener;

public class ReactAppCompatActivityDelegate {

	private static final String TAG = "Navigation";

	private final int REQUEST_OVERLAY_PERMISSION_CODE = 1111;
	private static final String REDBOX_PERMISSION_GRANTED_MESSAGE =
		"Overlay permissions have been granted.";
	private static final String REDBOX_PERMISSION_MESSAGE =
		"Overlay permissions needs to be granted in order for react native apps to run in dev mode";

	private final AppCompatActivity mActivity;
	private final ReactManager mReactManager;

	private @Nullable
	DoubleTapReloadRecognizer mDoubleTapReloadRecognizer;
	private @Nullable
	PermissionListener mPermissionListener;
	private @Nullable
	Callback mPermissionsCallback;

	public ReactAppCompatActivityDelegate(@NonNull AppCompatActivity activity, ReactManager reactManager) {
		mActivity = activity;
		mReactManager = reactManager;
	}

	private void askPermission() {
		ReactManager reactManager = getReactManager();
		DevSupportManager devSupportManager = reactManager.getDevSupportManager();
		if (devSupportManager != null) {
			FLog.i(TAG, "Check overlay permission");
			// Get permission to show redbox in dev builds.
			if (!Settings.canDrawOverlays(getContext())) {
				FLog.i(TAG, "Request overlay permission");
				Intent serviceIntent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getContext().getPackageName()));
				FLog.w(ReactConstants.TAG, REDBOX_PERMISSION_MESSAGE);
				Toast.makeText(getContext(), REDBOX_PERMISSION_MESSAGE, Toast.LENGTH_LONG).show();
				((Activity) getContext()).startActivityForResult(serviceIntent, REQUEST_OVERLAY_PERMISSION_CODE);
			}
		}
	}

	protected ReactManager getReactManager() {
		return mReactManager;
	}

	public ReactContext getCurrentReactContext() {
		return mReactManager.getCurrentReactContext();
	}

	ReactManager.ReactModuleRegisterListener mReactModuleRegisterListener = this::askPermission;

	protected void onCreate(Bundle savedInstanceState) {
		mDoubleTapReloadRecognizer = new DoubleTapReloadRecognizer();
		if (mReactManager.isReactModuleRegisterCompleted()) {
			askPermission();
		} else {
			mReactManager.addReactModuleRegisterListener(mReactModuleRegisterListener);
		}
	}

	protected void onDestroy() {
		mReactManager.removeReactModuleRegisterListener(mReactModuleRegisterListener);
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onHostDestroy(getPlainActivity());
	}

	protected void onResume() {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onHostResume(getPlainActivity(), (DefaultHardwareBackBtnHandler) getPlainActivity());
		if (mPermissionsCallback != null) {
			mPermissionsCallback.invoke();
			mPermissionsCallback = null;
		}
	}

	protected void onPause() {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onHostPause(getPlainActivity());
	}

	public boolean onBackPressed() {
		ReactHost reactHost = mReactManager.getReactHost();
		return reactHost.onBackPressed();
	}

	public boolean onNewIntent(Intent intent) {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onNewIntent(intent);
		return true;
	}

	public void onUserLeaveHint() {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onHostLeaveHint(getPlainActivity());
	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onActivityResult(getPlainActivity(), requestCode, resultCode, data);
	}

	public void onWindowFocusChanged(boolean hasFocus) {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onWindowFocusChange(hasFocus);
	}

	public void onConfigurationChanged(Configuration newConfig) {
		ReactHost reactHost = mReactManager.getReactHost();
		reactHost.onConfigurationChanged(getPlainActivity());
	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		DevSupportManager devSupportManager = mReactManager.getDevSupportManager();
		if (devSupportManager != null && keyCode == KeyEvent.KEYCODE_MEDIA_FAST_FORWARD) {
			event.startTracking();
			return true;
		}
		return false;
	}

	public boolean onKeyUp(int keyCode, KeyEvent event) {
		return shouldShowDevMenuOrReload(keyCode, event);
	}

	public boolean onKeyLongPress(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_MEDIA_FAST_FORWARD || keyCode == KeyEvent.KEYCODE_BACK) {
			DevSupportManager devSupportManager = mReactManager.getDevSupportManager();
			if (devSupportManager != null) {
				devSupportManager.showDevOptionsDialog();
				return true;
			}
		}
		return false;
	}

	public boolean shouldShowDevMenuOrReload(int keyCode, KeyEvent event) {
		DevSupportManager devSupportManager = mReactManager.getDevSupportManager();
		if (devSupportManager == null) {
			return false;
		}

		if (keyCode == KeyEvent.KEYCODE_MENU) {
			devSupportManager.showDevOptionsDialog();
			return true;
		}

		if (mDoubleTapReloadRecognizer != null &&
			mDoubleTapReloadRecognizer.didDoubleTapR(keyCode, getPlainActivity().getCurrentFocus())) {
			devSupportManager.handleReloadJS();
			return true;
		}

		return false;
	}

	public void requestPermissions(String[] permissions, int requestCode, PermissionListener listener) {
		mPermissionListener = listener;
		getPlainActivity().requestPermissions(permissions, requestCode);
	}

	public void onRequestPermissionsResult(final int requestCode, final String[] permissions, final int[] grantResults) {
		mPermissionsCallback = args -> {
			if (mPermissionListener != null
				&& mPermissionListener.onRequestPermissionsResult(
					requestCode, permissions, grantResults)) {
				mPermissionListener = null;
			}
		};
	}

	private Context getContext() {
		return Assertions.assertNotNull(mActivity);
	}

	private Activity getPlainActivity() {
		return ((Activity) getContext());
	}

}
